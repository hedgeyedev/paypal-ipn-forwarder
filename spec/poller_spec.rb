require_relative 'spec_helper'
require_relative '../lib/poller'
require_relative '../lib/router'

describe Poller do

  TEST_MODE_ON = true

  before(:each) do
    @router = Router.new(nil, TEST_MODE_ON)
    @server_url = 'my_sandbox_id'
    @router.sandbox_id=(@server_url)
    @url = 'dummy_url'
    @poller = Poller.new(@router, @url)
  end

  it 'should send a GET request' do
    RestClient.should_receive(:get).with('dummy_url', @server_url)
    @poller.retrieve_ipn
  end

  it 'polls at specified intervals' do
    RestClient.should_receive(:get).with('dummy_url', @server_url).twice
    @poller.time_in_sec=0.02
    @polling_count = 2
    @poller.poll_for_ipn(self)

  end

  def  keep_polling?
    @polling_count -= 1
    @polling_count > 0
  end


  it 'retrieves an ipn when the server has one to return' do
    RestClient.should_receive(:get).with('dummy_url', @server_url)
    @poller.retrieve_ipn
  end

  it


end
