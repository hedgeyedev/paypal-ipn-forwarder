require 'rspec'
require_relative '../lib/server_client'
require_relative '../lib/server'
require_relative '../lib/ipn_generator'

describe ServerClient do

  TEST_MODE_ON = true


    #TODO: fix tests so the pass with CGI
  it 'should receive a testing ON HTTP request from the router and tell the server to turn test mode ON' do
    server = Server.new(TEST_MODE_ON)
    server.should_receive(:begin_test_mode).with('my_sandbox_id', {'sandbox_id' => ['my_sandbox_id'], 'test_mode' => ['on'], 'email' => ['bob@example.com']})

    server_client = ServerClient.new(server)
    server_client.computer_testing( {'sandbox_id' => ['my_sandbox_id'], 'test_mode' => ['on'], 'email' => ['bob@example.com']})

  end

  it 'should receive a testing OFF HTTP request from the router and tell the server to turn test mode OFF' do
    server = Server.new(TEST_MODE_ON)
    server.should_receive(:cancel_test_mode).with('my_sandbox_id')

    server_client = ServerClient.new(server)
    server_client.computer_testing({'sandbox_id' => ['my_sandbox_id'], 'test_mode' => ['off'], 'email' => ['bob@example.com']})
  end

  it 'should receive a poll from a development computer and respond to it' do
    server = Server.new(TEST_MODE_ON)
    server_client = ServerClient.new(server)
    ipn_generator = IpnGenerator.new
    ipn = ipn_generator.ipn
    server_client.computer_testing({'sandbox_id' => ['my_sandbox_id'], 'test_mode' => ['on'], 'email' => ['bob@example.com']})
    server.queue_push(ipn)
    server_client.respond_to_computer_poll('my_sandbox_id').should == ipn

  end


  it 'should receive IPNs and forward them to the server' do
    server = mock('server')
    server.stub(:receive_ipn).with('an ipn')
    server_client = ServerClient.new(server)
    server_client.receive_ipn('an ipn')
  end

  it 'should create the response to a sandbox when the sandbox sent an IPN' do
    server = mock('server')
    server_client = ServerClient.new(server)
    ipn_generator = IpnGenerator.new
    ipn = ipn_generator.ipn
    server_client.ipn_response(ipn).should == ipn_generator.verified_ipn

  end

  it 'receives a "test mode on" message for a paypal sandbox which is already being used for IPN testing and send out emails' do
    Pony.should_receive(:mail).with(any_args).twice
    server = Server.new(TEST_MODE_ON)
    server_client = ServerClient.new(server)
    @my_id = 'my_sandbox_id'
    server_client.computer_testing({'sandbox_id' => [@my_id], 'test_mode' => ['on'], 'email' => ['bob@example.com']})
    server.computer_online?(@my_id).should == true
    server.same_sandbox_being_tested_twice?(@my_id, {'sandbox_id' => [@my_id], 'test_mode' => ['on'], 'email' => ['bob1@example.com']}).should == true
    server_client.computer_testing({'sandbox_id' => [@my_id], 'test_mode' => ['on'], 'email' => ['bob1@example.com']})
  end

  #TODO: fix test so passes with CGI
  it 'receives a "test mode on" message for a paypal sandbox which is already being used for IPN testing' do
    Pony.should_receive(:mail).with(any_args).twice
    server = Server.new(TEST_MODE_ON)
    @my_id = 'my_sandbox_id'
    server_client = ServerClient.new(server)
    server_client.computer_testing({'sandbox_id' => [@my_id], 'test_mode' => ['on'], 'email' => ['bob@example.com']})
    server_client.computer_testing({'sandbox_id' => [@my_id], 'test_mode' => ['on'], 'email' => ['bob_1@example.com']})
  end

end