require_relative 'spec_helper'
require_relative '../lib/paypal_test'

describe PaypalTest do

  before(:each) do
    @paypal_test = PaypalTest.new
  end

  it 'start testing' do
    @paypal_test.process_id.should_not be nil
    @paypal_test.start
  end

  it 'stop testing' do
    @paypal_test.process_id.should be nil
    @paypal_test.stop
  end

end