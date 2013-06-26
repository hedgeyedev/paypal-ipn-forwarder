require_relative 'spec_helper'
require_relative '../lib/mail_sender'
require_relative '../lib/mail_creator'

describe MailSender do

  YAML_HASH = {
    'first' => 'the_worst',
    'second' => 'the_best',
    'third' => 'the_hairy_chest'
     }
    EX = {
      'bob' => 'thebuilder',
      'luke' => 'skywalker'
    }
    COMBINED = {
      'bob' => 'thebuilder',
      'luke' => 'skywalker',
      'first' => 'the_worst',
      'second' => 'the_best',
      'third' => 'the_hairy_chest'
    }
    TO = {
      :to => 'dmitri.ostapenko@gmail.com',
      :body => 'this is a test email body message. HEY scott or Dmitri or James',
      :subject => 'test email from hedgeye. is this working? '
    }
  it 'should create the email content from mail_sender' do
    sender = MailSender.new
    hash = sender.create(EX)
    YAML_HASH.each_key do |key|
      YAML_HASH[key].should == hash[key]
    end
  end

  it 'should send an email' do
    sender = MailSender.new
    hash = sender.create(TO)
    sender.send_email
  end

end