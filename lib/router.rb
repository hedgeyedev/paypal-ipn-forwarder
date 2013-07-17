require_relative 'poller'
require_relative 'load_config'

class Router

  PROCESS_FILE_NAME = '.process_id'

  TEST_ON = 'on'
  TEST_OFF = 'off'

  attr_accessor :sandbox_id

  def initialize(target, test=nil)
    @development_computer  = target
    LoadConfig.set_test_mode(!test.nil?)
    config = LoadConfig.new
    @server_url = config.server_url
  end


  def forward_ipn(ipn)
    if (ipn == 'VERIFIED')
      send_verified
    else
      send_ipn(ipn)
    end
  end

  def polling_interval
  end

  def send_verified
    @development_computer.send_verified
  end

  def send_ipn(ipn)
    @development_computer.send_ipn(ipn)
  end

  def test_mode_on(email)
    set_test_mode(TEST_ON, email)

  end

  def test_mode_off(email)
    set_test_mode(TEST_OFF, email)
  end

  private

  def set_test_mode(mode, email)
    RestClient.post(@server_url, { params: { my_id: @sandbox_id, test_mode: mode, email: email
    } })
  end

end
