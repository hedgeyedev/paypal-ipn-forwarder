require_relative 'poller'

class Router

  PROCESS_FILE_NAME = '.process_id'

  TEST_ON = 'on'
  TEST_OFF = 'off'

  attr_accessor :sandbox_id
   #TODO: rename dev_computer to router Client
  def initialize(target, test=nil)
    @router_client  = target
  end

  def send_ipn(ipn)
    @router_client.send_ipn(ipn)
  end

  def turn_test_mode_on(email)
    @router_client.set_test_mode(TEST_ON, email, @sandbox_id)
  end

  #TODO there is nothing calling this method currently. Make sure it is hardwired in or test mode will never be turned off
  def turn_test_mode_off(email)
    @router_client.set_test_mode(TEST_OFF, email, @sandbox_id)
  end

end
