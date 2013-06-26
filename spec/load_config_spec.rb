require 'rspec'
require_relative '../lib/load_config'

describe LoadConfig do

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

end
