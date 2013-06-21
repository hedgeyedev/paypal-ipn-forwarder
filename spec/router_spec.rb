require 'rspec'
require_relative '../lib/router'

describe Router do

  context 'when created' do

    it 'tells the server that test mode has started'

    it 'starts polling the server'

  end

  context 'exists' do

    before(:each) do
      @router = Router.new
    end

    context 'when destroying' do

      it 'stops polling the server'

      it 'tells the server that test mode has finished'

      it 'self-destructs'

    end

    context 'polling retrieves an IPN' do

      it 'retrieves an IPN when the server has one to return'

      it 'initiates a protocol to send the IPN to cms'

      it 'polls the server again 5 seconds after finishing the protocol with cms'

    end

    context 'polling does not retrieve an IPN' do

      it 'polls again 5 seconds later'

    end

    context 'handshake between router and CMS' do

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
38416&payment_type=instant&last_name=User&address_state=CA&receiver_email=email\
&payment_fee=0.88&receiver_id=S8XGHLYDW9T3S\
&txn_type=express_checkout&item_name=&mc_currency=USD&item_number=&residenc\
e_country=US&test_ipn=1&handling_amount=0.00&transaction_subject=&payment_g\
ross=19.95&shipping=0.00
EOF
      end

      def create_ipn_response_somehow
        verified_ipn = <<EOF
cmd=_notify-validate&mc_gross=19.95&protection_eligibility=Eligible&address_status=confirmed&pay\
er_id=LPLWNMTBWMFAY&tax=0.00&address_street=1+Main+St&payment_date=20%3A12%\
3A59+Jan+13%2C+2009+PST&payment_status=Completed&charset=windows-\
1252&address_zip=95131&first_name=Test&mc_fee=0.88&address_country_code=US&\
address_name=Test+User&notify_version=2.6&custom=&payer_status=verified&add\
ress_country=United+States&address_city=San+Jose&quantity=1&verify_sign=Atk\
OfCXbDm2hu0ZELryHFjY-Vb7PAUvS6nMXgysbElEn9v-\
1XcmSoGtf&payer_email=gpmac_1231902590_per%40paypal.com&txn_id=61E67681CH32\
38416&payment_type=instant&last_name=User&address_state=CA&receiver_email=email\
&payment_fee=0.88&receiver_id=S8XGHLYDW9T3S\
&txn_type=express_checkout&item_name=&mc_currency=USD&item_number=&residenc\
e_country=US&test_ipn=1&handling_amount=0.00&transaction_subject=&payment_g\
ross=19.95&shipping=0.00
EOF
      end

      before(:each) do
        @cms = mock('CMS Ipn server')
      end

      # TODO: @cms and @router are going to have to be tied together
      #this fails. has to be changed to fit with new implementation
      it 'processes an IPN' do
        ipn          = create_an_ipn_somehow
        ipn_response = create_ipn_response_somehow
        @cms.stub!(:send_ipn).with(ipn).and_return(ipn_response).to(self)
        @cms.should_receive(:verified)
        @router.send_ipn(ipn)
      end

      it 'polls the server for a verfication message'

      it 'send a verification message'

    end

  end

end
