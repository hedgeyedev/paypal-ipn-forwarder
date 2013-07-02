require_relative 'spec_helper'
require_relative '../lib/poller'
require_relative '../lib/router'
require_relative '../lib/server'

describe Poller do

  TEST_MODE_ON = true

  before(:each) do
    @router = Router.new(nil, TEST_MODE_ON)
    @server_url = 'my_sandbox_id'
    @router.sandbox_id=(@server_url)
    @url = 'dummy_url'
    @poller = Poller.new(@router, @url)
  end

  it 'should send a GET request' do
    RestClient.should_receive(:get).with('dummy_url', @server_url)
    @poller.retrieve_ipn
  end

  it 'polls at specified intervals' do
    RestClient.should_receive(:get).with('dummy_url', @server_url).twice
    @poller.time_in_sec=0.02
    @polling_count = 2
    @poller.poll_for_ipn(self)

  end

  def  keep_polling?
    @polling_count -= 1
    @polling_count > 0
  end

  def create_an_ipn_somehow
    sample_ipn = <<EOF
mc_gross=19.95&protection_eligibility=Eligible&address_status=confirmed&pay\
er_id=LPLWNMTBWMFAY&tax=0.00&address_street=1+Main+St&payment_date=20%3A12%\
3A59+Jan+13%2C+2009+PST&payment_status=Completed&charset=windows-\
1252&address_zip=95131&first_name=Test&mc_fee=0.88&address_country_code=US&\
address_name=Test+User&notify_version=2.6&custom=&payer_status=verified&add\
ress_country=United+States&address_city=San+Jose&quantity=1&verify_sign=Atk\
OfCXbDm2hu0ZELryHFjY-Vb7PAUvS6nMXgysbElEn9v-\
1XcmSoGtf&payer_email=gpmac_1231902590_per%40paypal.com&txn_id=61E67681CH32\
38416&payment_type=instant&last_name=User&address_state=CA&receiver_email=gpmac_1231902686_biz%40paypal.com\
&payment_fee=0.88&receiver_id=my_sandbox_id\
&txn_type=express_checkout&item_name=&mc_currency=USD&item_number=&residenc\
e_country=US&test_ipn=1&handling_amount=0.00&transaction_subject=&payment_g\
ross=19.95&shipping=0.00
EOF
  end

  it 'retrieves an ipn when the server has one to return' do
    RestClient.should_receive(:get).with('dummy_url', @server_url)
    server = Server.new(TEST_MODE_ON)
    server.computer_testing({'my_id' => @server_url, 'test_mode' => 'on', 'email' => 'bob@example.com'})
    server.receive_ipn(create_an_ipn_somehow)
    @poller.retrieve_ipn
    server.respond_to_computer_poll(@server_url).should == create_an_ipn_somehow

  end


end
