require 'timecop'
require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/poller'
require_relative '../lib/paypal-ipn-forwarder/router'
require_relative '../lib/paypal-ipn-forwarder/load_config'

describe PaypalIpnForwarder::Poller do

  TEST_MODE_ON = true

  before(:each) do
    @router = PaypalIpnForwarder::Router.new(nil)
    content = PaypalIpnForwarder::LoadConfig.new(TEST_MODE_ON)
    @sandbox_id = 'my_sandbox_id'
    @url = content.server_url
    @router.sandbox_id=(@sandbox_id)
    @poller = PaypalIpnForwarder::Poller.new(@router, @url)
    @time_before_no_ipn_notification = content.no_ipn_time_before_notification
  end

  it 'should send a GET request' do
    RestClient.should_receive(:get).with('http://localhost:8810/computer_poll', {:params=>{'sandbox_id'=>'my_sandbox_id'}})
    @poller.retrieve_ipn
  end

  it 'polls at specified intervals' do
    RestClient.should_receive(:get).with('http://localhost:8810/computer_poll', {:params=>{'sandbox_id'=>'my_sandbox_id'}}).twice
    @poller.time_in_sec=0.02
    @polling_count = 2
    @poller.poll_for_ipn(self)

  end

  def  keep_polling?
    @polling_count -= 1
    @polling_count > 0
  end


  it 'retrieves an ipn when the server has one to return' do
    RestClient.should_receive(:get).with('http://localhost:8810/computer_poll', {:params=>{'sandbox_id'=>'my_sandbox_id'}})
    @poller.retrieve_ipn
  end

  it 'alerts the developer if an error occurs during a poll' do
    STDOUT.should_receive(:puts).with('There is a problem regarding the connection to the server. A SystemCallError occured. Please check the server is online and that test mode has occurred. Check your inbox in case another developer attempted to turn on test mode for your sandbox')
    @poller.retrieve_ipn
  end

  it 'should alert the developer if an IPN has not been received 10 minutes after testing has started' do
    STDOUT.should_receive(:puts).with('an IPN has still not been received, 10 minutes after testing')
    @poller.time_polling_started = Time.now
    Timecop.travel(Time.now+@time_before_no_ipn_notification)
    @poller.verify_ipn_received(1)

  end


end
