require 'rspec'
require 'pony'
require 'pony'
require 'timecop'

require_relative '../lib/server_poll_checker'
require_relative '../lib/server'


describe ServerPollChecker do

  before(:each) do
    @server = Server.new(true)
    @sp_checker = ServerPollChecker.new(@server, true)
  end

  it 'should record the time that an unexpected poll comes in and send an email' do
    Pony.should_receive(:mail).with(any_args)
    time = Time.now
    @sp_checker.poll_time('my_sandbox_id', time)
    @sp_checker.last_unexpected_poll.should == time
  end

  it 'should not record a poll if it occurrs within 24 hours of last email notification sent out' do
    Pony.should_receive(:mail).with(any_args)
    time = Time.now - 60.0
    @sp_checker.poll_time('my_sandbox_id', time)
    @sp_checker.poll_time('my_sandbox_id', Time.now)
    @sp_checker.last_unexpected_poll.should == time
  end

  it 'should send an email to a developer if unexpected poll comes in 24 hours after initial' do
    Pony.should_receive(:mail).with(any_args).twice
    time = Time.now
    @sp_checker.poll_time('my_sandbox_id', time)
    time_fast_forward = Time.now + 24*60*60
    @sp_checker.poll_time('my_sandbox_id', time_fast_forward)
  end

  it 'should send an email notification if polling has not occured within an hour of test mode being turned on and repeat to do three times' do
    Pony.should_receive(:mail).with(any_args).exactly(3).times
    @sp_checker.record_poll_time('my_sandbox_id')
    @sp_checker.check_testing_polls_occurring('my_sandbox_id', 0.1)
  end

  it 'should turn off test mode once three emails have been sent warning of no polling occuring' do
    Pony.should_receive(:mail).with(any_args).exactly(3).times
    @sp_checker.record_poll_time('my_sandbox_id')
    @sp_checker.check_testing_polls_occurring('my_sandbox_id', 0.1)
    @server.computer_online?('my_sandbox_id').should == false
  end
end

