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
    dev_id = 'my_sandbox_id'
    @server.computer_testing({'my_id' => dev_id, 'test_mode' => 'on'})
    @server.receive_ipn(ipn)
    ipn_retrieved = @server.send_ipn(dev_id)
    computer = DevelopmentComputer.new
    computer.receive_ipn(ipn_retrieved)
    computer.ipn.should == ipn

  end

  it 'notifies the developers that a new sanbox is sending emails and that that sandbox is unregistered' do
    Pony.should_receive(:mail).with({:via => :smtp,
                                     :to => "dmitri.ostapenko@gmail.com",
                                     :from => "email-proxy-problems@superbox.com",
                                     :subject => "There is no queue on the Superbox IPN forwared",
                                     :body => "on the Superbox IPN forwarder, there is no queue set up for this function: \"queue push\" for your developer_id",
                                     :via_options =>
                                         {:address => "localhost",
                                          :openssl_verify_mode => "none"}
                                    })
    sb = Sandbox.new
    ipn = sb.send_fail
    @server.computer_testing({'my_id' => 'my_sandbox_id', 'test_mode' => 'on'})
    sandbox_id = @server.receive_ipn(ipn)
  end


  it 'does not forward an ipn to a computer from a paypal sandbox that doesn\'t belong to it' do
    sb = Sandbox.new
    ipn = sb.send
    id_1 = 'my_sandbox_id_1'
    id_2 = 'my_sandbox_id'
    @server.computer_testing({'my_id' => id_1, 'test_mode' => 'on'})
    @server.computer_testing({'my_id' => id_2, 'test_mode' => 'on'})
    @server.receive_ipn(ipn)
    @server.ipn_present?(id_1).should == false
    @server.send_ipn(id_1).should == nil
  end

  it 'records that it has received an IPN response from a specific development computer' do
    computer = DevelopmentComputer.new
    @server.computer_testing({'my_id' => 'my_sandbox_id', 'test_mode' => 'on'})
    ipn_response = computer.send_ipn_response
    @server.receive_ipn_response(ipn_response)
    paypal_id = @server.paypal_id(ipn_response)
    @server.ipn_response_present?(paypal_id).should == true
  end

  it 'confirms a IPN response for a polling request from the router for that IPN response' do
    computer = DevelopmentComputer.new
    ipn_response = computer.send_ipn_response
    @server.receive_ipn_response(ipn_response)
    paypal_id = @server.paypal_id(ipn_response)
    @server.ipn_response_present?(paypal_id).should == true

  end

  it 'denies an IPN response for a polling request from a router because no IPN exists for that router' do
    dev_id = 'my_sandbox_id'
    @server.ipn_response_present?(dev_id).should == false
    @server.respond_to_computer_poll(dev_id).should == nil
  end

  context 'queue' do

    before(:each) do
      @sb = Sandbox.new
      @my_id = 'my_sandbox_id'
      @server.computer_testing({'my_id' => @my_id, 'test_mode' => 'on'})
    end

    it 'stores IPNs sent from a sandbox when a computer is testing' do
      ipn = @sb.send
      @server.receive_ipn(ipn)
      ipn.should == @server.queue_pop(@my_id)
      #what happens if there are 2 developers testing. Intresting scenario which needs discussion
    end

    it 'does not store IPNs which are generated from recurring payments' do
      ipn = @sb.send_recurring
      @server.receive_ipn(ipn)
      @server.queue_size(@my_id).should == 0
    end
  end

  it 'stores the time that a computer polls'

  it 'receives a "test mode on" message for a paypal sandbox which is already being used for IPN testing'

  context 'receives polling request without test mode activated' do

    it 'send an email to the developer, if one is on file'

    it 'sends another notification if issue not handled 24 hours after previous email'

    it 'sends email to all developers if no email on file'

  end

end
