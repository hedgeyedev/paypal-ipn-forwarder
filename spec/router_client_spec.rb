require 'rspec'
require 'rest_client'
require_relative '../lib/paypal-ipn-forwarder/router_client'

describe PaypalIpnForwarder::RouterClient do

  TEST_MODE = true

  before(:each) do
    @dev_computer = PaypalIpnForwarder::RouterClient.new(TEST_MODE)
  end

  it 'should forward an ipn' do
    RestClient.should_receive(:post).with('http://localhost:3000/payments/ipn', 'sample_IPN')
    @dev_computer.send_ipn('sample_IPN')
  end

  it 'should send a HTTP request telling server that test mode has turned on' do
    RestClient.should_receive(:post).with('http://localhost:8810/test', {'sandbox_id'=>'my_sandbox_id', 'test_mode'=>'on', 'email'=>'bob@example.com'})
    @dev_computer.set_test_mode('on', 'bob@example.com', 'my_sandbox_id')
  end


end
