require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/host_info'
require_relative '../lib/paypal-ipn-forwarder/mail_sender'
require_relative '../lib/paypal-ipn-forwarder/mail_creator'

describe PaypalIpnForwarder::MailSender do

  MAIL_PARAMS = {
      to:      'bob@example.com',
      from:    'james@example.com',
      title:   'this works! awesome',
      subject: 'hey, look this went through'
  }

  TO_EMAIL = 'developer@gmail.com'
  TO_BODY = 'this is a test email body message. HEY scott or Dmitri or James'
  TO_SUBJECT = 'test email from hedgeye. is this working?'

  TO = {
      :to => TO_EMAIL,
      :body => TO_BODY,
      :subject => TO_SUBJECT
  }

  TEST_MODE_ON = true

  it 'should create the email content from mail_sender' do
    PaypalIpnForwarder::HostInfo.stub!(:running_on_osx?).and_return(true)
    sender = PaypalIpnForwarder::MailSender.new
    sender.create(MAIL_PARAMS).length.should == 4
  end

  it 'should send an email' do
    PaypalIpnForwarder::HostInfo.stub!(:running_on_osx?).and_return(false)
    Pony.should_receive(:mail).with({:to => TO_EMAIL,
                                     :body => TO_BODY,
                                     :subject => TO_SUBJECT,
                                     :from    => 'email-proxy@paypal-ipn-forwarder.com',
                                     :via => :smtp,
                                     :via_options => {
                                         :address => '0.0.0.1',
                                         :openssl_verify_mode => 'none'}, :subject => TO_SUBJECT })
    sender = PaypalIpnForwarder::MailSender.new
    sender.send(TO[:to], TO[:subject], TO[:body])
  end

end
