require_relative 'spec_helper'
require_relative '../lib/server'
require_relative '../lib/ipn_generator'
require_relative '../lib/router_client'

describe Server do

  TEST_MODE_ON = true

  before(:each) do
    @server = Server.new(TEST_MODE_ON)
    @my_id = 'my_sandbox_id'
  end

  it 'responds to a poll request with an IPN when one is present' do
    sb = IpnGenerator.new
    ipn = sb.send
    @server.computer_testing({'my_id' => @my_id, 'test_mode' => 'on', '@email' => 'bob@example.com'})
    @server.receive_ipn(ipn)
    paypal_id = @server.paypal_id(ipn)
    @server.ipn_present?(paypal_id).should == true
    @server.send_ipn_if_present(paypal_id).should == ipn
  end

  it 'does not forward an ipn to a computer from a paypal sandbox that doesn\'t belong to it' do
    sb = IpnGenerator.new
    ipn = sb.send
    id_1 = 'my_sandbox_id_1'
    id_2 = 'my_sandbox_id'
    @server.computer_testing({'my_id' => id_1, 'test_mode' => 'on'})
    @server.computer_testing({'my_id' => id_2, 'test_mode' => 'on'})
    @server.receive_ipn(ipn)
    @server.ipn_present?(id_1).should == false
    @server.send_ipn_if_present(id_1).should == nil
  end

  #TODO: fix this
  it 'records that it has received an IPN response from a specific development computer' do
    computer = RouterClient.new
    @server.computer_testing({'my_id' => 'my_sandbox_id', 'test_mode' => 'on'})
    @server.receive_ipn_response(ipn_response)
    paypal_id = @server.paypal_id(ipn_response)
    @server.ipn_response_present?(paypal_id).should == true
  end

   #TODO delete once ipn response is linked to testing computer
  it 'confirms a IPN response for a polling request from the router for that IPN response' do
    computer = RouterClient.new
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
      @ipn_generator = IpnGenerator.new
      @my_id = 'my_sandbox_id'
      @server.computer_testing({'my_id' => @my_id, 'test_mode' => 'on', 'email' => 'bob@example.com'})
    end

    it 'stores IPNs sent from a sandbox when a computer is testing' do
      ipn = @ipn_generator.ipn
      @server.receive_ipn(ipn)
      paypal_id = @server.paypal_id(ipn)
      @server.queue_size(paypal_id).should == 1
      ipn.should == @server.queue_pop(@my_id)
    end

    it 'does NOT store IPNs sent from a sandbox when a computer is NOT testing' do
      ipn = @ipn_generator.fake_email
      @server.receive_ipn(ipn)
      @server.queue_size(@my_id).should == 0
    end

    it 'purges an IPN once it has been sent to the computer' do
      ipn = @ipn_generator.ipn
      paypal_id = @server.paypal_id(ipn)
      @server.queue_push(ipn)
      @server.send_ipn_if_present(paypal_id)
      @server.queue_size(paypal_id).should == 0
    end

  end

  it 'receives a "test mode on" message for a paypal sandbox which is already being used for IPN testing' do
    Pony.should_receive(:mail).with(any_args).twice
    @server.computer_testing({'my_id' => @my_id, 'test_mode' => 'on', 'email' => 'bob@example.com'})
    @server.computer_testing({'my_id' => @my_id, 'test_mode' => 'on', 'email' => 'bob_1@example.com'})
  end


  context 'receives polling request without test mode activated' do

    it 'should should send email to the developer, if one is on file' do
      Pony.should_receive(:mail).with({:via => :smtp,
                                       :to => "dmitri.ostapenko@gmail.com",
                                       :from => "email-proxy-problems@superbox.com",
                                       :subject => "A problem occured on the IPN proxy with sandbox my_sandbox_id",
                                       :body => "Your computer made an unexpected poll on the Superbox IPN forwarder. The poll occurred before test mode was turned on. The sandox id is my_sandbox_id.This problem is happening on a superbox belonging to you so this email was only sent to you. Please address it",
                                       :via_options =>
                                           {
                                               :address => "localhost",
                                               :openssl_verify_mode => "none"
                                           }
                                      })

      @server.respond_to_computer_poll(@my_id)
    end

    it 'should sends email to all developers if no email on file' do
      Pony.should_receive(:mail).with(any_args).twice
      @server.respond_to_computer_poll('my_sandbox_unknown')
    end

    it 'should send another notification email if last email sent 24 ago as issue still not resolved' do
      Pony.should_receive(:mail).with(any_args).twice
      time = Time.now - 12*60*60
      @server.respond_to_computer_poll('my_sandbox_unknown', time)
      time_new = Time.now + 12*60*60
      @server.respond_to_computer_poll('my_sandbox_unknown', time_new)
    end
  end

  context 'receives start test mode' do

    #not sure if test is too basic but added just in case
    it 'begins testings'

    it 'records the time that test mode was started'
  end

end
