require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/host_info'
require_relative '../lib/paypal-ipn-forwarder/mail_sender'
require_relative '../lib/paypal-ipn-forwarder/mail_creator'

include PaypalIpnForwarder

describe MailSender do

  MAIL_PARAMS = {
      to:      'bob@example.com',
      from:    'james@example.com',
      title:   'this works! awesome',
      subject: 'hey, look this went through'
  }

  TO_EMAIL = 'developer@gmail.com'
  TO_BODY = 'Test email body'
  TO_SUBJECT = 'Test Email Subject'

  TO = {
      :to => TO_EMAIL,
      :body => TO_BODY,
      :subject => TO_SUBJECT
  }

  TEST_MODE_ON = true

  before do
    @host = HostInfo.new
    @mail_creator = MailCreator.new(@host)
    @mail_sender = MailSender.new(@mail_creator)
  end
  it 'should create the email content from mail_sender' do
    @host.stub!(:running_on_osx?).and_return(true)
    Pony.should_receive(:mail).with({:to => TO_EMAIL,
                                     :body => TO_BODY,
                                     :subject => TO_SUBJECT,
                                     :from    => 'email-proxy@paypal-ipn-forwarder.com'})
    @mail_sender.send_mail(TO_EMAIL, TO_SUBJECT, TO_BODY)
  end

  it 'should send an email' do
    @host.stub!(:running_on_osx?).and_return(false)
    Pony.should_receive(:mail).with({:to => TO_EMAIL,
                                     :subject => TO_SUBJECT,
                                     :body => TO_BODY,
                                     :from    => 'email-proxy@paypal-ipn-forwarder.com',
                                     :via => :smtp,
                                     :via_options => {
                                         :address => '0.0.0.1',
                                         :openssl_verify_mode => 'none'}})
    @mail_sender.send_mail(TO[:to], TO[:subject], TO[:body])
  end

end
