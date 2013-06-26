require 'rspec'
require_relative '../lib/load_config'

describe 'LoadConfig' do

  before(:each) do
    LoadConfig.set_test_mode
    @config = LoadConfig.new
  end

  it 'retrieves the server URL' do
    @config.server_url.should == 'http://your_server.example.com'
  end


  it 'retrieves the developer computer URL for the router to send IPNs to' do
    @config.development_computer_url.should == 'http://localhost:3000/payments/ipn'
  end

  it 'retrieves the number of seconds between polls' do
    @config.polling_interval_seconds.should == '5.0'
  end


  it 'retrieves the constantr email info' do
    @config.mail_creator.should == {:via=>:smtp, :via_options=>{:address=>"0.0.0.1", :openssl_verify_mode=>"none"}}
  end

  it 'loads the sandbox ids ' do
    @config.sandbox_ids.should == ['1.1.1.1.1', '0.10.0.0']
  end


end
