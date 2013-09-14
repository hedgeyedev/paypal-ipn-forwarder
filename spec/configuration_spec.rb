require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/server'
require_relative '../lib/paypal-ipn-forwarder/ipn_generator'

describe PaypalIpnForwarder::Server do

  before(:each) do
    @server = PaypalIpnForwarder::Server.new(TEST_MODE_ON)
    @server.begin_test_mode('my_sandbox_id', { 'my_sandbox_id' => 'my_sandbox_id', 'test_mode' => 'on', '@email' => 'bob@example.com' })
  end

  it 'turns on test mode for a computer once it receives a test-mode message' do
    @server.computer_online?('my_sandbox_id').should == true
  end

  describe 'routing' do

    TEST_MODE_ON = true

    it 'retrieves the Paypal sandbox id from the IPN' do
      ipn_generator = PaypalIpnForwarder::IpnGenerator.new
      sample_ipn    = ipn_generator.ipn
      ap sample_ipn;1
      paypal_id     = @server.paypal_id(sample_ipn)
      paypal_id.should == 'my_sandbox_id'
    end

  end
end
