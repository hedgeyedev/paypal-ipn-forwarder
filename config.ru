require 'sinatra/base'
require 'rest_client'
require 'cgi'
require_relative './lib/paypal-ipn-forwarder/ipn'
require_relative './lib/paypal-ipn-forwarder/server_client'
require_relative './lib/paypal-ipn-forwarder/server'
require_relative './lib/paypal-ipn-forwarder/poller'
require_relative './lib/paypal-ipn-forwarder/ipn_generator'
require_relative './lib/paypal-ipn-forwarder/router_client'
require_relative './lib/paypal-ipn-forwarder/mail_sender'

# This is the configuration for running the 'server' on the public-facing server
# and also the 'server_client' which runs on the developer's laptop.
class ServerRack < Sinatra::Base
  configure do
    TEST_MODE_ON = true
    @@server = Server.new
    @@server_client = ServerClient.new(@@server)
    @@router = RouterClient.new
    @@mail = MailSender.new
  end

  # Send a test ipn to the development computer as though the PayPal sandbox sent it.
  # This command is received from the router and sent by the router.
  get '/invoke_ipn' do
    ipn_send_test = IpnGenerator.new
    ipn_send_test.send_via_http 'localhost:8810/payments/ipn'
  end

  # Poll the server to see if it has anything for the router to do.
  # This command is sent by the router.
  get '/computer_poll' do
    params = request['sandbox_id']
    @@server_client.respond_to_computer_poll(params) unless params.nil? || params.length == 0
  end

  # Receive an ipn.  Typically this is sent by the router to the server.
  post '/payments/ipn' do
    ipn_str = request.body.read
    ipn = Ipn.new(ipn_str)
    if @@server.ipn_valid?(ipn)
      @@server_client.receive_ipn(ipn)
      response = @@server_client.ipn_response(ipn_str)
      url      = 'https://www.sandbox.paypal.com/cgi-bin/webscr'
      #used for testing
      #url = 'localhost:6810/receive_ipn/'
      @@server_client.send_response_to_paypal(url, response)
    end
  end

  # Request server to change test mode for a developer and his PayPal sandbox.
  post '/test' do
    params = request.body.read
    params_parsed = Rack::Utils.parse_nested_query(params)
    id = params_parsed['sandbox_id']
    email = params_parsed['email']
    test_mode = params_parsed['test_mode']
    if id != '' && email != '' && test_mode != ''
      @@server_client.computer_testing(params_parsed)
    elsif email != ''
      @@server.poll_with_incomplete_info(email, test_mode, id)
    end
    Rack::Utils.status_code(:ok)
  end

  # Pretend to be the PayPal sandbox you're sending the response back to
  post '/fake_paypal' do
    url = 'localhost:8810/receive_ipn/'
    RestClient.post url, 'VERIFIED'
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
    @@server.computer_online?('id@example.com')
  end

  get '/hello' do
    'hello scott'
  end

  post '/show_ipn' do
    ipn = Ipn.new(request.body.read)
    @@server.printo(ipn)
  end

  get '/send_email' do
    params = request['email']
    @@mail.send(params, 'This is a test email from the Paypal IPN forwarder', 'hello from the imac' )
  end


  run! if __FILE__ == $0


end

run ServerRack.new



