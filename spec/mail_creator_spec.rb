require 'awesome_print'
require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/load_config'
require_relative '../lib/paypal-ipn-forwarder/mail_sender'
require_relative '../lib/paypal-ipn-forwarder/mail_creator'

describe PaypalIpnForwarder::MailCreator do

  include PaypalIpnForwarder::HostInfo

  NEEDED_BY_LINUX     = {
      via:         :smtp,
      via_options: { address: '0.0.0.1', openssl_verify_mode: 'none' }
  }
  FED_IN_PARAMS = {
      to:      'bob@example.com',
      from:    'james@example.com',
      title:   'this works! awesome',
      subject: 'hey, look this went through'
  }
  COMBINED      = FED_IN_PARAMS.merge(NEEDED_BY_LINUX)


  it 'should put together the fed-in parameters into the hash' do
    mail_creator = PaypalIpnForwarder::MailCreator.new(PaypalIpnForwarder::LoadConfig::SET_TEST_MODE)
    mail_creator.create_email
    hash = mail_creator.combine_params(NEEDED_BY_LINUX)
    NEEDED_BY_LINUX.each_key do |key|
      NEEDED_BY_LINUX[key].should == hash[key]
    end
  end

  it 'should combine the fed-in parameters and the Linux-specific parameters' do
    stub!(:running_on_osx).and_return(false)
    mail_creator = PaypalIpnForwarder::MailCreator.new(PaypalIpnForwarder::LoadConfig::SET_TEST_MODE)
    hash  = mail_creator.create(FED_IN_PARAMS)
    ap COMBINED;1
    COMBINED.each_key do |key|
      COMBINED[key].should == hash[key]
    end
  end


end
