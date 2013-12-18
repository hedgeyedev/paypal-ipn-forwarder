require 'rspec'
require_relative '../lib/paypal-ipn-forwarder/router'
require_relative '../lib/paypal-ipn-forwarder/poller'
require_relative '../lib/paypal-ipn-forwarder/server_client'
require_relative '../lib/paypal-ipn-forwarder/load_config'
require_relative '../lib/paypal-ipn-forwarder/ipn'
require_relative '../lib/paypal-ipn-forwarder/ipn_generator'
require_relative '../lib/paypal-ipn-forwarder/router_client'

include PaypalIpnForwarder
describe Router do

  TEST_MODE_ON = true

  before(:each) do
    @router_client = RouterClient.new(TEST_MODE_ON)
    content = LoadConfig.new(TEST_MODE_ON)
    @server_url = content.server_url + 'test'
    @router = Router.new(@router_client)
    @router.sandbox_id=('my_sandbox_id')
    @poller = Poller.new(@router, @server_url)
    @email = 'bob@example.com'
    @sandbox_id = 'my_sandbox_id'
  end

  context 'interactions with server' do

    it 'developer notified that router can not reach the server when starting test mode' do
      STDOUT.should_receive(:puts).with('The connection to the server is experiencing errors. Test mode was NOT turned on. Make sure the server is running!')
      @router.turn_test_mode_on('bob@example.com')
    end

    context 'test mode' do

      def expected_rest_client_message(mode)
        @email = 'bob@example.com'
        RestClient.should_receive(:post).with(@server_url, {'sandbox_id' => @sandbox_id,
                                                            'test_mode' => mode,
                                                            'email' => @email
        })
      end

      it 'has started' do
        expected_rest_client_message(Router::TEST_ON)
        @router.turn_test_mode_on(@email)
      end

      it 'has stopped' do
        expected_rest_client_message(Router::TEST_OFF)
        @router.turn_test_mode_off(@email)
      end

    end

  end

  context 'handshake between router and development computer' do

    def create_an_ipn_somehow
      Ipn.generate.ipn_str
    end

    def create_ipn_response_somehow
      ipn_gen = IpnGenerator.new
      ipn = ipn_gen.verified_ipn
    end

    it 'automatically identifies the developer computer' do
      @router.sandbox_id.should == @sandbox_id

    end

    it 'processes an IPN' do
      ipn = create_an_ipn_somehow
      @router_client.stub!(:send_ipn).with(ipn)
      @router.send_ipn(ipn)

    end
  end
end
