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

  get '/computer_poll' do
    #TODO: figure out what occurs if params nill
    params = request['sandbox_id']
    @@server_client.respond_to_computer_poll(params)
  end

  post '/payments/ipn' do
    ipn = request.body.read
    unless ipn == 'VERIFIED' || ipn == 'INVALID'
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
    @@server_client.computer_testing(params)
  end

  # Pretend to be the PayPal sandbox you're sending the response back to
  post '/fake_payal' do
    url = 'localhost:8810/receive_ipn/'
    RestClient.post url, "VERIFIED"
  end

  get '/' do
    "Hello Wofrld"
  end

  get '/turn_testing_on' do
    @@router.set_test_mode('on', 'bib@example.com', 'my_sandbox_id')
  end

  get '/start_computer_poll' do
    poller = Poller.new(nil, 'http://localhost:8810/', 'my_sandbox_id')
    poller.retrieve_ipn
  end

  post '/message' do
    ipn = request.body.read
  end

  run! if __FILE__ == $0


end

run ServerRack.new



