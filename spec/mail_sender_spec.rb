require_relative 'spec_helper'
require_relative '../lib/mail_sender'
require_relative '../lib/send_grid_mail_creator'

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
  it 'should create the email content from mail_sender' do
    sender = MailSender.new
    hash = sender.create(EX)
    YAML_HASH.each_key do |key|
      YAML_HASH[key].should == hash[key]
    end
  end


end