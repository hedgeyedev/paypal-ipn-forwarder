require 'rspec'
require_relative '../lib/paypal-ipn-forwarder/ipn'
require_relative '../lib/paypal-ipn-forwarder/ipn_generator'

include PaypalIpnForwarder
describe IpnGenerator do

  before(:each) do
    @ipn_generator = IpnGenerator.new
    @ipn = Ipn.generate
  end

  it 'should send a sample IPN for testing' do
    RestClient.should_receive(:post).with('sample_url', @ipn.ipn_str)
    @ipn_generator.send_via_http('sample_url')

  end
end
