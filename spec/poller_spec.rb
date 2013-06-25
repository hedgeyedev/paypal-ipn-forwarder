require_relative 'spec_helper'
require_relative '../lib/poller'
require_relative '../lib/router'

describe Poller do

  before(:each) do
    @router = Router.new
    @url = 'dummy_url'
    @poller = Poller.new(@router, @url)
    @rest_client = Object.new.extend RestClient
  end
  it 'should send a GET request' do
    @router.stub!(:ip_address).and_return('target_ip')
    @rest_client.class.should_receive(:get).with(@url, 'target_ip')

  end

  it 'polls at specified intervals'


end