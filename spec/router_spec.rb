require 'rspec'

require_relative '../lib/router'

describe Router do

  context 'when created' do

    it 'tells the server that test mode has started'

    it 'starts polling the server'

  end

  context 'exists' do

    @router = Router.new

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
        raise "solve this problem"
      end

      def create_a_success_ipn_response_somehow
        raise "solve this problem"
      end

      def create_a_failure_ipn_response_somehow
        raise 'solve this problem'
      end

      before(:each) do
        @cms = mock('CMS Ipn server')
      end

      # TODO: @cms and @router are going to have to be tied together

      it 'verifies when CMS processes an IPN successfully' do
        ipn          = create_an_ipn_somehow
        ipn_response = create_a_success_ipn_response_somehow
        @cms.stub!(:send_ipn).with(ipn).and_return(ipn_response)
        @cms.should_receive(:verified)
        @router.send_ipn(ipn)
      end

      it 'reports invalid when CMS does not process the IPN successfully' do
        ipn          = create_an_ipn_somehow
        ipn_response = create_a_failure_ipn_response_somehow
        @cms.stub!(:send_ipn).with(ipn).and_return(ipn_response)
        @cms.should_receive(:notvalid)
        @router.send_ipn(ipn)
      end

    end

  end

end
