require_relative 'spec_helper'
require_relative '../lib/server'
require_relative '../lib/sandbox'
require_relative '../lib/development_computer'


describe Server do

  it 'forwards an ipn from a paypal sandbox to its corresponding computer' do
    sb = Sandbox.new
    ipn = sb.send
    server = Server.new(true)
    sandbox_id = server.receive_ipn(ipn)
    computer = DevelopmentComputer.new
    computer.receive_ipn(ipn)
    computer.ipn.should == ipn

  end


  it 'does not forward an ipn to a computer from a paypal sandbox that doesn\'t belong to it' do
      sb = Sandbox.new
      ipn = sb.send_fail
      server = Server.new(true)
      sandbox_id = server.receive_ipn(ipn)
      comp_id = server.computer_id(sandbox_id)
      comp_id.should == nil
      computer = DevelopmentComputer.new
      computer.receive_ipn(ipn) unless comp_id == nil
      computer.ipn.should == nil
  end

  it 'records that it has received an IPN response from a specific development computer' do
    server = Server.new(true)
    computer = DevelopmentComputer.new
    ipn_response = computer.send_ipn_response
    server.receive_ipn_response(ipn_response)
    paypal_id = server.paypal_id(ipn_response)
    computer_id = server.computer_id(paypal_id)
    server.ipn_response_present?(computer_id).should == true
  end

  it 'confirms a IPN response for a polling request from the router for that IPN response' do
    server = Server.new(true)
    computer = DevelopmentComputer.new
    ipn_response = computer.send_ipn_response
    server.receive_ipn_response(ipn_response)
    paypal_id = server.paypal_id(ipn_response)
    computer_id = server.computer_id(paypal_id)
    server.ipn_response_present?(computer_id).should == true

  end

  it 'denies an IPN response for a polling request from a router because none exists' do
    server = Server.new(true)
    server.ipn_response_present?('developer_one').should == false
  end

  context 'queue' do
    it 'stores IPNs sent from a sandbox when a computer is testing' do
      server = Server.new(true)
      sb = Sandbox.new
      dev_id = 'developer_one'
      server.computer_testing(dev_id)
      ipn = sb.send
      server.receive_ipn(ipn)
      server.create_queue
      server.queue_push(ipn)
      ipn.should == server.queue_pop
      #what happens if there are 2 developers testing. Intresting scenario which needs discussion
    end

    it 'does not store IPNs which are generated from recurring payments'
  end
end
