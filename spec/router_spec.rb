require 'rspec'
require_relative '../lib/router'
require_relative '../lib/poller'
require_relative '../lib/server'

describe Router do

  before(:each) do
    @target     = mock('target')
    @router     = Router.new(@target)
    @server_url = YAML::load_file(File.expand_path('../../config/config.yml', __FILE__))
    @poll       = Poller.new(@router, @server_url)
  end

  context 'interactions with server' do

    context 'test mode' do

      def expected_rest_client_message(mode)
        RestClient.should_receive(:post).with(@server_url, { params: { my_ip:     @router.my_ip_address,
                                                                       test_mode: mode
        } })
      end

      it 'has started' do
        expected_rest_client_message('on')
        @router.test_mode_on
      end

      # FIXME or get rid of me
      #it 'stops polling the server' do
      #  @router.test_mode_on
      #  @router.test_mode_off
      #end

      it 'has stopped' do
        expected_rest_client_message('off')
        @router.test_mode_off
      end

    end

    context 'polling retrieves an IPN' do

      it 'initiates a protocol to send the IPN to the development computer' do
        RestClient.should_receive(:post).with(@server_url, @router.my_ip_address)
      end

    end

  end

  context 'handshake between router and development computer' do

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

    it 'automatically identifies the developer computer' do
      @router.my_ip_address.should =~ /\d+\.\d+\.\d+\.\d+/
    end

    # TODO: development computer and @router are going to have to be tied together
    it 'processes an IPN' do
      ipn          = create_an_ipn_somehow
      ipn_response = create_ipn_response_somehow
      @target.stub!(:send_ipn).with(ipn).and_return(ipn_response)
      @router.forward_ipn(ipn)

    end

    it 'send a verification message' do
      @target.should_receive(:verified)
      server = Server.new
      server.store_ipn_response('developer_one')
      server.send_response_to_computer('developer_one').should == 'VERIFIED'
      @router.forward_ipn(server.send_response_to_computer('developer_one'))
    end

  end

end
