require 'rspec'
require 'pony'
require 'timecop'

require_relative '../lib/paypal-ipn-forwarder/server_poll_checker'
require_relative '../lib/paypal-ipn-forwarder/server'

include PaypalIpnForwarder

TEST_MODE_ON = true

describe ServerPollChecker do

  before(:each) do
    @server = Server.new(TEST_MODE_ON)
    @sp_checker = ServerPollChecker.new(@server, TEST_MODE_ON)
  end

  it 'records the time that test mode was started or the last poll occurred' do
    time = Time.now
    paypal_id = 'my_sandbox_id'
    @sp_checker.record_poll_time(paypal_id, time)
    @sp_checker.last_poll_time(paypal_id).should == time

  end

  it 'should record the time that an unexpected poll comes in and send an email' do
    Pony.should_receive(:mail).with(any_args)
    time = Time.now
    @sp_checker.unexpected_poll_time('my_sandbox_id', time)
    @sp_checker.last_unexpected_poll.should == time
  end

  it 'should not record an unexpected poll if it occurs within 24 hours of last email notification sent out' do
    Pony.should_receive(:mail).with(any_args)
    time = Time.now - 60.0
    @sp_checker.unexpected_poll_time('my_sandbox_id', time)
    @sp_checker.unexpected_poll_time('my_sandbox_id', Time.now)
    @sp_checker.last_unexpected_poll.should == time
  end

  it 'should send an email to a developer if unexpected poll comes in 24 hours after initial' do
    Pony.should_receive(:mail).with(any_args).twice
    time = Time.now
    @sp_checker.unexpected_poll_time('my_sandbox_id', time)
    time_fast_forward = Time.now + 24*60*60
    @sp_checker.unexpected_poll_time('my_sandbox_id', time_fast_forward)
  end

  it 'should send an email notification if polling has not occurred within an hour of test mode being turned on and repeat notification three times if not fixed' do
    Pony.should_receive(:mail).with(any_args).exactly(3).times
    @server.begin_test_mode('my_sandbox_id', {'sandbox_id' => 'my_sandbox_id', 'test_mode' => 'on', 'email' => 'bob@example.com'})
    @sp_checker.record_poll_time('my_sandbox_id')
    @sp_checker.check_testing_polls_occurring('my_sandbox_id', 0.4)
  end

  it 'should turn off test mode once three emails have been sent warning of no polling occurring' do
    Pony.should_receive(:mail).with(any_args).exactly(3).times
    @server.begin_test_mode('my_sandbox_id', {'sandbox_id' => 'my_sandbox_id', 'test_mode' => 'on', 'email' => 'bob@example.com'})
    @sp_checker.record_poll_time('my_sandbox_id')
    @sp_checker.check_testing_polls_occurring('my_sandbox_id', 0.4)
    @server.computer_online?('my_sandbox_id').should == false
  end

  it 'should not send an email if last incomplete information poll was less than hour ago' do
      Pony.should_receive(:mail).with(any_args)
      @sp_checker.email_developer_incomplete_request('email@email', 'off', '')
      @sp_checker.email_developer_incomplete_request('email@email', 'off', '', Time.now + 10)
  end
end

