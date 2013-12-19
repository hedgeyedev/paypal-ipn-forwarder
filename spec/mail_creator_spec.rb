require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/host_info'
require_relative '../lib/paypal-ipn-forwarder/mail_creator'

include PaypalIpnForwarder

describe MailCreator do

  MAIL_PARAMS = {
      to:      'bob@example.com',
      from:    'james@example.com',
      title:   'this works! awesome',
      subject: 'hey, look this went through'
  }

  context 'OSX' do

    it 'should not include Linux parameters' do
      MailCreator.new.create(MAIL_PARAMS).length.should == 4
    end

  end

  context 'linux parameters' do

    def setup_test
      host = HostInfo.new
      host.stub!(:running_on_osx?).and_return(false)
      MailCreator.new(host).create(MAIL_PARAMS)
    end

    it 'should contain Linux mail configuration parameters under Linux' do
      mail_hash = setup_test
      mail_hash[:via].should == :smtp
      mail_hash[:via_options].should == {
          :address             => '0.0.0.1',
          :openssl_verify_mode => 'none' }
    end
  end

end
