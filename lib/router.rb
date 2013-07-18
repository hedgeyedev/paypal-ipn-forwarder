require_relative 'poller'

class Router

  PROCESS_FILE_NAME = '.process_id'

  TEST_ON = 'on'
  TEST_OFF = 'off'

  attr_accessor :sandbox_id

  def initialize(target, test=nil)
    @development_computer  = target
  end

  def send_ipn(ipn)
    @development_computer.send_ipn(ipn)
  end

  def test_mode_on(email)
    @development_computer.set_test_mode(TEST_ON, email, @sandbox_id)
  end

  def test_mode_off(email)
    @development_computer.set_test_mode(TEST_OFF, email, @sandbox_id)
  end

end
