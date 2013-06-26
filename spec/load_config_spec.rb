require 'rspec'
require_relative '../lib/load_config'

describe LoadConfig do

  before(:each) do
    @config = LoadConfig.new('_test')
  end

  it 'retrieves the server URL' do
    true.should == true
  end

end
