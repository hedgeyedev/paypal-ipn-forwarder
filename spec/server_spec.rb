require_relative 'spec_helper'
require_relative '../lib/server'
require_relative '../lib/sandbox'
require_relative '../lib/development_computer'

describe Server do

  TEST_MODE_ON = true
  before(:each) do
    @server = Server.new(TEST_MODE_ON)
  end

  it 'forwards an ipn from a paypal sandbox to its corresponding computer' do
    sb = Sandbox.new
    ipn = sb.send
    sandbox_id = @server.receive_ipn(ipn)
    computer = DevelopmentComputer.new
    computer.receive_ipn(ipn)
    computer.ipn.should == ipn

  end


  it 'does not forward an ipn to a computer from a paypal sandbox that doesn\'t belong to it' do
    sb = Sandbox.new
    ipn = sb.send_fail
    sandbox_id = @server.receive_ipn(ipn)
    comp_id = @server.computer_id(sandbox_id)
    comp_id.should == nil
    computer = DevelopmentComputer.new
    computer.receive_ipn(ipn) unless comp_id == nil
    computer.ipn.should == nil
  end

  it 'records that it has received an IPN response from a specific development computer' do
    computer = DevelopmentComputer.new
    ipn_response = computer.send_ipn_response
    @server.receive_ipn_response(ipn_response)
    paypal_id = @server.paypal_id(ipn_response)
    computer_id = @server.computer_id(paypal_id)
    @server.ipn_response_present?(computer_id).should == true
  end

  it 'confirms a IPN response for a polling request from the router for that IPN response' do
    computer = DevelopmentComputer.new
    ipn_response = computer.send_ipn_response
    @server.receive_ipn_response(ipn_response)
    paypal_id = @server.paypal_id(ipn_response)
    computer_id = @server.computer_id(paypal_id)
    @server.ipn_response_present?(computer_id).should == true

  end

  it 'denies an IPN response for a polling request from a router because none exists' do
    @server.ipn_response_present?('developer_one').should == false
  end

  context 'queue' do
    it 'stores IPNs sent from a sandbox when a computer is testing' do
      sb = Sandbox.new
      my_id = 'my_sandbox_id'
      dev_id = 'developer_one'
      @server.computer_testing({'my_id' => my_id, 'test_mode' => 'on'})
      ipn = sb.send
      @server.receive_ipn(ipn)
      ipn.should == @server.queue_pop(my_id)
      #what happens if there are 2 developers testing. Intresting scenario which needs discussion
    end

    it 'does not store IPNs which are generated from recurring payments'
  end
end
