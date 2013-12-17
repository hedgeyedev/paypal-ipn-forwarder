require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/server'
require_relative '../lib/paypal-ipn-forwarder/ipn'

include PaypalIpnForwarder

describe Server do

  TEST_MODE_ON = true

  before(:each) do
    @server = PaypalIpnForwarder::Server.new(TEST_MODE_ON)
    @server.begin_test_mode('my_sandbox_id', { 'my_sandbox_id' => 'my_sandbox_id', 'test_mode' => 'on', '@email' => 'bob@example.com' })
  end

  it 'turns on test mode for a computer once it receives a test-mode message' do
    @server.computer_online?('my_sandbox_id').should == true
  end

  describe 'routing' do

    it 'retrieves the Paypal sandbox id from the IPN' do
      sample_ipn    = Ipn.generate
      paypal_id     = sample_ipn.paypal_id
      paypal_id.should == 'gpmac_1231902686_biz@paypal.com'
    end

  end
end
