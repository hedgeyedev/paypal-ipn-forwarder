require_relative 'spec_helper'
require_relative '../lib/server'
require_relative '../lib/ipn_generator'

  describe Server do

  before(:each) do
    @server = Server.new(TEST_MODE_ON)
    @server.computer_testing({'my_id' => 'my_sandbox_id', 'test_mode' => 'on', 'email' => 'bob@example.com'})
  end

  it 'turns on test mode for a computer once it receives a test-mode message' do
    @server.computer_online?('my_sandbox_id').should == true
  end

  describe 'routing' do

    TEST_MODE_ON = true

    it 'retrieves the Paypal sandbox id from the IPN' do
      ipn_generator = IpnGenerator.new
      sample_ipn = ipn_generator.ipn
      paypal_id = @server.paypal_id(sample_ipn)
      paypal_id.should == 'my_sandbox_id'
    end




  end
end