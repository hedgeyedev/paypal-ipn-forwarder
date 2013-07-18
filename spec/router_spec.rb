require 'rspec'
require_relative '../lib/router'
require_relative '../lib/poller'
require_relative '../lib/server_client'
require_relative '../lib/load_config'
require_relative '../lib/ipn_generator'
require_relative '../lib/router_client'

describe Router do

  TEST_MODE_ON = true

  before(:each) do
    @development_computer = RouterClient.new(TEST_MODE_ON)
    LoadConfig.set_test_mode(true)
    content = LoadConfig.new
    @server_url = content.server_url
    @server_client = ServerClient.new
    @router = Router.new(@development_computer, TEST_MODE_ON)
    @router.sandbox_id=('my_sandbox_id')
    @poller = Poller.new(@router, @server_url)
    @email = 'bob@example.com'
    @my_id = 'my_sandbox_id'
  end

  context 'interactions with server' do

    context 'test mode' do

      def expected_rest_client_message(mode)
        @email = 'bob@example.com'
        RestClient.should_receive(:post).with(@server_url, {params: {my_id: @my_id,
                                                                     test_mode: mode,
                                                                     :email => @email,
        }})
      end

      it 'has started' do
        expected_rest_client_message(Router::TEST_ON)
        @router.test_mode_on(@email)
      end

      it 'has stopped' do
        expected_rest_client_message(Router::TEST_OFF)
        @router.test_mode_off(@email)
      end

    end

  end

  context 'handshake between router and development computer' do

    def create_an_ipn_somehow
      ipn_gen = IpnGenerator.new
      ipn = ipn_gen.ipn
    end

    def create_ipn_response_somehow
      ipn_gen = IpnGenerator.new
      ipn = ipn_gen.verified_ipn
    end

    it 'automatically identifies the developer computer' do
      @router.sandbox_id.should == @my_id

    end

    it 'processes an IPN' do
      ipn = create_an_ipn_somehow
      ipn_response = create_ipn_response_somehow
      @development_computer.stub!(:send_ipn).with(ipn).and_return(ipn_response)
      @router.send_ipn(ipn)

    end

  end

end
