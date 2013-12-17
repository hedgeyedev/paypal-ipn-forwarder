require 'rest-client'

module PaypalIpnForwarder
  class ServerClient

    def initialize(server)
      @server = server
    end

    def computer_testing(params_parsed)
      id = params_parsed['sandbox_id']
      if params_parsed['test_mode'] == 'on'
        if !@server.computer_online?(id)
          @server.begin_test_mode(id, params_parsed)
        elsif @server.same_sandbox_being_tested_twice?(id, params_parsed)
          @server.send_conflict_email(id, params_parsed['email'])
          @server.cancel_test_mode(id)
        end
      elsif params_parsed['test_mode'] == 'off'
        @server.cancel_test_mode(id)
      end
    end

    def respond_to_computer_poll(paypal_id, now=Time.now)
      @server.record_computer_poll(paypal_id)
      if (@server.computer_online?(paypal_id))
        @server.send_ipn_if_present(paypal_id)
      else
        @server.unexpected_poll(paypal_id)
      end
    end

    def ipn_response(ipn)
      'cmd=_notify-validate&' + ipn
    end

    # @param [String] ipn_str the PayPal string representation
    def receive_ipn(ipn_str)
      @server.receive_ipn(Ipn.new(ipn_str))
    end

    def send_paypal_response(url, message)
      RestClient.post url, message
    end

  end
end
