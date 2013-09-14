require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/mail_sender'
require_relative '../lib/paypal-ipn-forwarder/mail_creator'

describe PaypalIpnForwarder::MailSender do

  YAML_HASH = {
      :via => :smtp,
      :via_options => {:address => '0.0.0.1', :openssl_verify_mode => 'none'}
  }
  FED_IN_PARAMS = {
      'to' => 'bob@example.com',
      'from' => 'james@example.com',
      'title' => 'this works! awesome',
      'subject' => 'hey, look this went through'
  }
  COMBINED = {
      :via => :smtp,
      :via_options => {:address => '0.0.0.1', :openssl_verify_mode => 'none'},
      'to' => 'bob@example.com',
      'from' => 'james@example.com',
      'title' => 'this works! awesome',
      'subject' => 'hey, look this went through'
  }
  TO = {
      :to => 'developer@gmail.com',
      :body => 'this is a test email body message. HEY scott or Dmitri or James',
      :subject => 'test email from hedgeye. is this working? '
  }

  TEST_MODE_ON = true

  it 'should create the email content from mail_sender' do
    sender = MailSender.new
    hash = sender.create(FED_IN_PARAMS, MailCreator.new(TEST_MODE_ON))
    YAML_HASH.each_key do |key|
      YAML_HASH[key].should == hash[key]
    end
  end

  it 'should send an email' do
    Pony.should_receive(:mail).with({:to => 'developer@gmail.com',
                                     :body => 'this is a test email body message. HEY scott or Dmitri or James',
                                     :subject => 'test email from hedgeye. is this working? ',
                                     :via => :smtp,
                                     :via_options => {
                                         :address => '0.0.0.1',
                                         :openssl_verify_mode => 'none'}, :subject => 'test email from hedgeye. is this working? '})
    sender = MailSender.new
    hash = sender.create(TO, MailCreator.new(TEST_MODE_ON))
    sender.send_email

  end
end
