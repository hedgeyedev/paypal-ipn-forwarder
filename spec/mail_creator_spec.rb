require 'awesome_print'
require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/host_info'
require_relative '../lib/paypal-ipn-forwarder/mail_sender'
require_relative '../lib/paypal-ipn-forwarder/mail_creator'

describe PaypalIpnForwarder::MailCreator do

  MAIL_PARAMS = {
      to:      'bob@example.com',
      from:    'james@example.com',
      title:   'this works! awesome',
      subject: 'hey, look this went through'
  }


  context 'linux parameters' do

    def setup_test(is_osx)
      PaypalIpnForwarder::HostInfo.stub!(:running_on_osx?).and_return(is_osx)
      mail_creator = PaypalIpnForwarder::MailCreator.new
      mail_creator.create(MAIL_PARAMS)
    end

    it 'should not be included when running on OSX' do
      setup_test(true).length.should == 4
    end

    it 'should be included when running under Linux' do
      setup_test(false).length.should == 6
    end

    it 'should contain Linux mail configuration parameters under Linux' do
      mail_hash = setup_test false
      mail_hash.keys.should include(:via_options)
      mail_hash.keys.should include(:via)
    end
  end

end
