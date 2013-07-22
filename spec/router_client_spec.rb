require 'rspec'
require 'rest_client'
require_relative '../lib/router_client'

describe RouterClient do

  TEST_MODE = true

  before(:each) do
    @dev_computer = RouterClient.new(TEST_MODE)
  end

  it 'should forward an ipn' do
    RestClient.should_receive(:post).with('http://localhost:3000/payments/ipn', 'sample_IPN')
    @dev_computer.send_ipn('sample_IPN')
  end

  it 'should send a HTTP request telling server that test mode has turned on'


end