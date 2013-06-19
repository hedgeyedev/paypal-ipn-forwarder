require_relative 'spec_helper'
require_relative '../lib/mail_sender'
require_relative '../lib/send_grid_mail_creator'

describe MailCreator do

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

  it 'should load a yml file with all the private options for sending an email' do
    sgrid = SendGridMailCreator.new
    hash = sgrid.load_yml
    YAML_HASH.each_key do |key|
      YAML_HASH[key].should == hash[key]
    end

  end

  it 'should put together the fed in paramaters into the hash' do
    sgrid = SendGridMailCreator.new
    sgrid.create_email
    hash = sgrid.combine_params(YAML_HASH)
    YAML_HASH.each_key do |key|
      YAML_HASH[key].should == hash[key]
    end
  end

  it 'should combine the fed in parameters and the private paramaters' do
    sgrid = SendGridMailCreator.new
    hash = sgrid.create(EX)
    YAML_HASH.each_key do |key|
      YAML_HASH[key].should == hash[key]
    end
  end

  it 'should overwrite paramaters that are handfed and match the YAML file paramaters'
  #or backwards? discuss which implmentation would be better with James or Scott

end