require 'rspec'
require_relative '../lib/paypal-ipn-forwarder/ipn'

include PaypalIpnForwarder

describe Ipn do

  before do
    @ipn = Ipn.generate
  end

  it 'identifies a unique ID for the PayPal sandbox' do
    @ipn.paypal_id.should == 'gpmac_1231902686_biz@paypal.com'
  end

  ['VERIFIED', 'INVALID', ''].each do |word|
    it "should reject IPNs which have a value of #{word}" do
      ipn = Ipn.new(word)
      ipn.ipn_valid?.should == false
    end
  end

end
