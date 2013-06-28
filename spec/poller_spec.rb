require_relative 'spec_helper'
require_relative '../lib/poller'
require_relative '../lib/router'

describe Poller do

  TEST_MODE_ON = true

  before(:each) do
    @router = Router.new(nil, TEST_MODE_ON)
    @url = 'dummy_url'
    @poller = Poller.new(@router, @url)
    #@rest_client = Object.new.extend RestClient
    @rest_client = mock('rest_client')
  end
  it 'should send a GET request' do
    #@router.stub!(:ip_address).and_return('target_ip')
    #@rest_client.class.should_receive(:get).with(@url, 'target_ip')

  end

  it 'polls at specified intervals'

  it 'retrieves an ipn when the server has one to return'


end