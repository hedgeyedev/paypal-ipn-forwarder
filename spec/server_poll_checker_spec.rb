require 'rspec'
require_relative '../lib/server_poll_checker'
require 'pony'

describe ServerPollChecker do

  before(:each) do
    @sp_checker = ServerPollChecker.new(true)
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
end