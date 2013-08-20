require 'rspec'
require_relative '../lib/ipn_generator'

describe IpnGenerator do

  before(:each) do
    @ipn_generator = IpnGenerator.new
    @ipn = @ipn_generator.ipn
  end

  it 'should send a sample IPN for testing' do
    RestClient.should_receive(:post).with('sample_url', @ipn)
    @ipn_generator.send_via_http('sample_url')

  end
end