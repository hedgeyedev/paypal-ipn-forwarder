require_relative 'poller'

class Router

  PROCESS_FILE_NAME = '.process_id'

  TEST_ON = 'on'
  TEST_OFF = 'off'

  attr_accessor :sandbox_id
  def initialize(target, test=nil)
    @router_client  = target
    @ipn_received = false
  end

  def send_ipn(ipn)
    @ipn_received = true
    @router_client.send_ipn(ipn)
  end

  def turn_test_mode_on(email)
    begin
      @router_client.set_test_mode(TEST_ON, email, @sandbox_id)
    rescue StandardError
      puts 'The connection to the server is experiencing errors. Test mode was NOT turned on. Make sure the server is running!'
    end
  end

  def turn_test_mode_off(email)
    begin
      @router_client.set_test_mode(TEST_OFF, email, @sandbox_id)
    rescue StandardError
      puts 'The connection to the server is not working. please make sure that TESTING IS TURNED OFF on the server
      otherwise IPN WILL CONTINUE TO ACCUMULATE'
    end
  end

end
