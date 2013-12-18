require 'rspec'
require_relative '../lib/paypal-ipn-forwarder/server_client'
require_relative '../lib/paypal-ipn-forwarder/server'
require_relative '../lib/paypal-ipn-forwarder/ipn'

include PaypalIpnForwarder

describe ServerClient do

  TEST_MODE_ON = true

  SANDBOX_INFO = { 'sandbox_id' => 'my_sandbox_id', 'test_mode' => 'on', 'email' => 'bob@example.com' }

  it 'should receive a testing ON HTTP request from the router and tell the server to turn test mode ON' do
    server = Server.new(TEST_MODE_ON)
    server.should_receive(:begin_test_mode).with('my_sandbox_id', SANDBOX_INFO)
    server_client = ServerClient.new(server)
    server_client.computer_testing(SANDBOX_INFO)
  end

  it 'should receive a testing OFF HTTP request from the router and tell the server to turn test mode OFF' do
    server = Server.new(TEST_MODE_ON)
    server.should_receive(:cancel_test_mode).with('my_sandbox_id')
    server_client = ServerClient.new(server)
    server_client.computer_testing({'sandbox_id' => 'my_sandbox_id', 'test_mode' => 'off', 'email' => 'bob@example.com'})
  end

  it 'should receive a poll from a development computer and respond to it' do
    server = Server.new(TEST_MODE_ON)
    server_client = ServerClient.new(server)
    ipn = Ipn.generate
    server_client.computer_testing(
        { 'sandbox_id' => ipn.paypal_id, 'test_mode' => 'on', 'email' => 'bob@example.com' }
    )
    server.queue_push(ipn)
    server_client.respond_to_computer_poll(ipn.paypal_id).should == ipn
  end


  it 'should receive IPNs and forward them to the server' do
    server = mock('server')
    ipn = Ipn.generate
    server.should_receive(:receive_ipn).with(ipn)
    server_client = ServerClient.new(server)
    server_client.receive_ipn(ipn)
  end

  it 'should create the response to a sandbox when the sandbox sent an IPN' do
    server = mock('server')
    server_client = ServerClient.new(server)
    ipn = Ipn.generate
    server_client.ipn_response(ipn.ipn_str).should == IpnGenerator.new.verified_ipn

  end

  it 'receives a "test mode on" message for a paypal sandbox which is already being used for IPN testing and send out emails' do
    Pony.should_receive(:mail).with(any_args).twice
    server = Server.new(TEST_MODE_ON)
    server_client = ServerClient.new(server)
    @my_id = 'my_sandbox_id'
    server_client.computer_testing({'sandbox_id' => @my_id, 'test_mode' => 'on', 'email' => 'bob@example.com'})
    server_client.computer_testing({'sandbox_id' => @my_id, 'test_mode' => 'on', 'email' => 'bob_1@example.com'})
  end

  it 'receives a "test mode on" message for a paypal sandbox which is already being used for IPN testing but does not send out email because it is the same person' do
    Pony.should_not_receive(:mail).with(any_args)
    server = Server.new(TEST_MODE_ON)
    @my_id = 'my_sandbox_id'
    server_client = ServerClient.new(server)
    server_client.computer_testing({'sandbox_id' => [@my_id], 'test_mode' => ['on'], 'email' => ['bob@example.com']})
    server_client.computer_testing({'sandbox_id' => [@my_id], 'test_mode' => ['on'], 'email' => ['bob@example.com']})
  end

end
