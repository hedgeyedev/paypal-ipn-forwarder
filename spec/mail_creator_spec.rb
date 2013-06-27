require_relative 'spec_helper'
require_relative '../lib/mail_sender'
require_relative '../lib/mail_creator'
describe MailCreator do

  YAML_HASH = {
      :via => :smtp,
      :via_options => {:address=>"0.0.0.1", :openssl_verify_mode=>"none"}
  }
  FED_IN_PARAMS = {
      'to' => 'bob@example.com',
      'from' => 'james@example.com',
      'title' => 'this works! awesome',
      'subject' => 'hey, look this went through'
  }
  COMBINED = {
      :via => :smtp,
      :via_options => {:address=>"0.0.0.1", :openssl_verify_mode=>"none"},
      'to' => 'bob@example.com',
      'from' => 'james@example.com',
      'title' => 'this works! awesome',
      'subject' => 'hey, look this went through'
  }


  it 'should put together the fed in paramaters into the hash' do
    sgrid = MailCreator.new(true)
    sgrid.create_email_hash
    hash = sgrid.combine_params(YAML_HASH)
    YAML_HASH.each_key do |key|
      YAML_HASH[key].should == hash[key]
    end
  end

  it 'should combine the fed in parameters and the private paramaters' do
    sgrid = MailCreator.new(true)
    hash = sgrid.create(FED_IN_PARAMS)
    COMBINED.each_key do |key|
      COMBINED[key].should == hash[key]
    end
  end

  it 'should overwrite paramaters that are handfed and match the YAML file paramaters'
  #or backwards? discuss which implmentation would be better with James or Scott

end