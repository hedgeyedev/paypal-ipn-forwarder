require_relative 'spec_helper'
require_relative '../lib/server'

describe Server do

  it 'has tests' do
    true.should be true
  end

  describe 'routing' do

    SAMPLE_IPN = <<EOF
mc_gross=19.95&protection_eligibility=Eligible&address_status=confirmed&pay\
er_id=LPLWNMTBWMFAY&tax=0.00&address_street=1+Main+St&payment_date=20%3A12%\
3A59+Jan+13%2C+2009+PST&payment_status=Completed&charset=windows-\
1252&address_zip=95131&first_name=Test&mc_fee=0.88&address_country_code=US&\
address_name=Test+User&notify_version=2.6&custom=&payer_status=verified&add\
ress_country=United+States&address_city=San+Jose&quantity=1&verify_sign=Atk\
OfCXbDm2hu0ZELryHFjY-Vb7PAUvS6nMXgysbElEn9v-\
1XcmSoGtf&payer_email=gpmac_1231902590_per%40paypal.com&txn_id=61E67681CH32\
38416&payment_type=instant&last_name=User&address_state=CA&receiver_email=g\
pmac_1231902686_biz%40paypal.com&payment_fee=0.88&receiver_id=S8XGHLYDW9T3S\
&txn_type=express_checkout&item_name=&mc_currency=USD&item_number=&residenc\
e_country=US&test_ipn=1&handling_amount=0.00&transaction_subject=&payment_g\
ross=19.95&shipping=0.00
EOF

    before(:each) do
      @server = Server.new
      @server.receive_ipn(SAMPLE_IPN)
    end

    it 'identifies the target computer from the IPN' do
      @server = Server.new
      @server.receive_ipn(SAMPLE_IPN)
      ipn = @server.ipn
      computer_id = @server.computer_id(@server.paypal_id(ipn))
      computer_id.should == 'developer_one'


    end

    it 'retrieves the Paypal sandbox id from the IPN' do
      @server = Server.new
      @server.receive_ipn(SAMPLE_IPN)
      ipn = @server.ipn
      actual_paypal_email_id = @server.paypal_id(ipn)
      actual_paypal_email_id.should == 'gpmac_1231902686_biz@paypal.com'
    end



  end
end