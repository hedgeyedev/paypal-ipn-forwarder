require 'rspec'
require 'rest_client'
require_relative '../lib/router_client'

describe RouterClient do

  TEST_MODE = true

  before(:each) do
    @dev_computer = RouterClient.new(TEST_MODE)
  end

  it 'should forward an ipn' do
    RestClient.should_receive(:post).with('b')#.with(anything, 'sample_IPN')
    @dev_computer.send_ipn('sample_IPN')
  end


  it 'should forward a VERIFIED message' do
    RestClient.should_receive(:post).with(anything, 'VERIFIED')
    @dev_computer.send_verified
  end

end