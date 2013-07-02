require 'rspec'
require_relative '../lib/router'
require_relative '../lib/poller'
require_relative '../lib/server_client'
require_relative '../lib/load_config'

describe Router do

  TEST_MODE_ON = true

  before(:each) do
    @development_computer = mock('development_computer')
    LoadConfig.set_test_mode(true)
    content = LoadConfig.new
    @dev_id = content.server_url
    @server_client = ServerClient.new(TEST_MODE_ON)
    @router = Router.new(@development_computer, TEST_MODE_ON)
    @router.sandbox_id=('my_sandbox_id')
    @poller = Poller.new(@router, @dev_id)
    @email = 'bob@example.com'
    @my_id = 'my_sandbox_id'
  end

  context 'interactions with server' do

    context 'test mode' do

      def expected_rest_client_message(mode)
        @email = 'bob@example.com'
        RestClient.should_receive(:post).with(@dev_id, {params: {my_id: @my_id,
                                                                     test_mode: mode,
                                                                     :email => @email
        }})
      end

      it 'has started' do
        expected_rest_client_message(Router::TEST_ON)
        @router.test_mode_on(@email)
      end

      # FIXME or get rid of me
      #it 'stops polling the server' do
      #  @router.test_mode_on
      #  @router.test_mode_off
      #end

      it 'has stopped' do
        expected_rest_client_message(Router::TEST_OFF)
        @router.test_mode_off(@email)
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
38416&payment_type=instant&last_name=User&address_state=CA&receiver_email=@email\
&payment_fee=0.88&receiver_id=my_sandbox_id\
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
38416&payment_type=instant&last_name=User&address_state=CA&receiver_email=@email\
&payment_fee=0.88&receiver_id=my_sandbox_id\
&txn_type=express_checkout&item_name=&mc_currency=USD&item_number=&residenc\
e_country=US&test_ipn=1&handling_amount=0.00&transaction_subject=&payment_g\
ross=19.95&shipping=0.00
EOF
    end

    it 'automatically identifies the developer computer' do
      @router.sandbox_id.should == @my_id

    end

    # TODO: development computer and @router are going to have to be tied together
    it 'processes an IPN' do
      ipn = create_an_ipn_somehow
      ipn_response = create_ipn_response_somehow
      @development_computer.stub!(:send_ipn).with(ipn).and_return(ipn_response)
      @router.forward_ipn(ipn)

    end

    it 'send a verification message' do
      @development_computer.should_receive(:send_verified)
      @server_client.stub!(:respond_to_computer_poll).with('my_sandbox_id').and_return('VERIFIED')
      @router.forward_ipn(@server_client.respond_to_computer_poll('my_sandbox_id'))
    end

  end

end
