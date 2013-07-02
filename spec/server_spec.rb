require_relative 'spec_helper'
require_relative '../lib/server'
require_relative '../lib/sandbox'
require_relative '../lib/development_computer'

describe Server do

  TEST_MODE_ON = true

  before(:each) do
    @server = Server.new(TEST_MODE_ON)
    @my_id = 'my_sandbox_id'
  end

  it 'forwards an ipn from a paypal sandbox to its corresponding computer' do
    sb = Sandbox.new
    ipn = sb.send
    dev_id = 'my_sandbox_id'
    @server.computer_testing({'my_id' => dev_id, 'test_mode' => 'on'})
    @server.receive_ipn(ipn)
    ipn_retrieved = @server.send_ipn_if_present(dev_id)
    computer = DevelopmentComputer.new
    computer.receive_ipn(ipn_retrieved)
    computer.ipn.should == ipn

  end

  #this test was erased because it is wrong. It is testing what happens when an (unknown or known) sandbox sends an IPN to the server
  #when it is non-testing. It should just be bounced and no email should be sent


  it 'does not forward an ipn to a computer from a paypal sandbox that doesn\'t belong to it' do
    sb = Sandbox.new
    ipn = sb.send
    id_1 = 'my_sandbox_id_1'
    id_2 = 'my_sandbox_id'
    @server.computer_testing({'my_id' => id_1, 'test_mode' => 'on'})
    @server.computer_testing({'my_id' => id_2, 'test_mode' => 'on'})
    @server.receive_ipn(ipn)
    @server.ipn_present?(id_1).should == false
    @server.send_ipn_if_present(id_1).should == nil
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
    @server.ipn_response_present?(@my_id).should == false
    @server.computer_testing({'my_id' => @my_id, 'test_mode' => 'on', '@email' => 'bob@example.com'})
    @server.respond_to_computer_poll(@my_id).should == nil
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
    end

  end

  it 'stores the time that a computer polls' do
    now = Time.now
    @server.computer_testing({'my_id' => @my_id, 'test_mode' => 'on', 'email' => 'bob@example.com'})
    @server.respond_to_computer_poll(@my_id, now)
    @server.last_computer_poll_time(@my_id).should == now


  end

  it 'receives a "test mode on" message for a paypal sandbox which is already being used for IPN testing' do
    Pony.should_receive(:mail).with(any_args).twice
    @server.computer_testing({'my_id' => @my_id, 'test_mode' => 'on', 'email' => 'bob@example.com'})
    @server.computer_testing({'my_id' => @my_id, 'test_mode' => 'on', 'email' => 'bob_1@example.com'})

  end


  context 'receives polling request without test mode activated' do

    it 'should send an request to mail_sender to send email to the developer, if one is on file' do
      Pony.should_receive(:mail).with(any_args)
      @server.unexpected_poll(@my_id)
    end

    it 'sends email to all developers if no email on file'



  end

end
