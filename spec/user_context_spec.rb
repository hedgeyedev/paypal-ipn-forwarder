require 'ostruct'
require 'yaml'
require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/user_context'

include PaypalIpnForwarder

describe 'UserContext' do

  before do
    @server = Server.new(TEST_MODE_ON)
  end

  it 'should load a file from YAML into OpenStruct' do
    begin
      my_array = Psych.load_file('user_context.yml')
      my_array.length.should == 2
      my_contexts = my_array.map { |hash| UserContext.new(@server, hash, TEST_MODE_ON) }
      my_contexts.length.should == 2
      c1 = my_contexts.first
      c1.paypal_id.should == 'my_sandbox_id'
      c1.email.should ==     'developer.gmail.com'
      c1.testing.should == false
      c1.queue_map.should be_a_kind_of(Hash)
      c1.last_poll_time.should be nil
      c1.poll_checker.should be_a_kind_of(ServerPollChecker)
      c1.ipn_reception_checker.should be_a_kind_of(ServerIpnReceptionChecker)
    rescue Psych::SyntaxError => ex
      puts 'exception file: ' + ex.file
      puts 'message: ' + ex.message
    end
  end

end
