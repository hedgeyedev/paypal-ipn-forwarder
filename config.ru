require 'sinatra/base'
require 'rest_client'
require 'cgi'
require File.expand_path('../lib/server_client', __FILE__)
require File.expand_path('../lib/server', __FILE__)
require File.expand_path('../lib/poller', __FILE__)
require File.expand_path('../lib/ipn_generator', __FILE__)
require File.expand_path('../lib/router_client', __FILE__)

class ServerRack < Sinatra::Base
  configure do
    TEST_MODE_ON = true
    @@server = Server.new(TEST_MODE_ON)
    @@server_client = ServerClient.new(@@server)
    @@router = RouterClient.new(TEST_MODE_ON)
  end

  get '/invoke_ipn' do
    ipn_send_test = IpnGenerator.new
    ipn_send_test.send_via_http "localhost:8810/payments/ipn"
  end

 #TODO: test DeMorgan's boolean statement
  get '/computer_poll' do
    params = request['sandbox_id']
    @@server_client.respond_to_computer_poll(params) unless params.nil? || params.length == 0
  end

  post '/payments/ipn' do
    ipn = request.body.read
    unless ipn.nil? || ipn =~ /(|VERIFIED|INVALID)/
      @@server_client.receive_ipn(ipn)
      response = @@server_client.ipn_response(ipn)
      url      = 'https://www.sandbox.paypal.com/cgi-bin/webscr'
      #used for testing
      #url = 'localhost:6810/receive_ipn/'
      @@server_client.send_paypal_response(url, response)
    end
  end

  post '/test' do

    params = request.body.read
    params_parsed = CGI::parse(params)
    id = params_parsed['sandbox_id'].first
    email = params_parsed['email'].first
    test_mode = params_parsed['test_mode'].first
    puts 'testing'
    if id != '' && email != '' && test_mode != ''
      @@server_client.computer_testing(params_parsed)
    elsif email != ''
       @@server.poll_with_incomplete_info(email, test_mode, id)
    end
  end

  # Pretend to be the PayPal sandbox you're sending the response back to
  post '/fake_paypal' do
    url = 'localhost:8810/receive_ipn/'
    RestClient.post url, "VERIFIED"
  end

  get '/' do
    halt(404)
  end

  get '/turn_testing_on' do
    @@router.set_test_mode('on', 'bob@example.com' , 'my_sandbox_id')
  end

  get '/start_computer_poll' do
    poller = Poller.new(nil, 'http://localhost:8810/', 'my_sandbox_id')
    poller.retrieve_ipn
  end

  post '/message' do
    ipn = request.body.read
  end

  get '/test_state' do
    @@server.computer_online?('my_sandbox_id')
  end


  run! if __FILE__ == $0


end

run ServerRack.new



