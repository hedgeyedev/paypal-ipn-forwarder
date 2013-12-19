require_relative 'poller'

module PaypalIpnForwarder
  class Router

    PROCESS_FILE_NAME = '.process_id'

    TEST_ON = 'on'
    TEST_OFF = 'off'

    attr_accessor :sandbox_id

    def initialize(target)
      @router_client = target
    end

    def send_ipn(ipn)
      @router_client.send_ipn(ipn)
    end

    def turn_test_mode_on(email)
      begin
        @router_client.set_test_mode(TEST_ON, email, @sandbox_id)
      rescue SystemCallError
        puts 'The connection to the server is experiencing errors. Test mode was NOT turned on. Make sure the server is running!'
      rescue StandardError
        puts 'Something went wrong while turning on test mode on the server. It was not a connection issue.Try running test using localhost to see what the mistake is. Also check your inbox for emails from the server. One possible scnerio is that the sanbx was already being used by a different developer'
      end
    end

    def turn_test_mode_off(email)
      begin
        @router_client.set_test_mode(TEST_OFF, email, @sandbox_id)
      rescue SystemCallError
        puts 'there was an error connecting to the server. please make sure that TESTING IS TURNED OFF on the server otherwise IPN WILL CONTINUE TO ACCUMULATE '
      rescue StandardError
        puts 'There was an error turning off testing on the server. please make sure that TESTING IS TURNED OFF on the server otherwise IPN WILL CONTINUE TO ACCUMULATE'
      end
    end

  end
end
