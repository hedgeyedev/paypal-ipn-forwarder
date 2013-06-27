require_relative 'poller'
require_relative 'load_config'

class Router

  PROCESS_FILE_NAME = '.process_id'

  TEST_ON = 'on'
  TEST_OFF = 'off'

  def initialize(target, test=nil)
    @target  = target
    LoadConfig.set_test_mode(!test.nil?)
    config = LoadConfig.new
    @server_url = config.server_url
  end

  def sandbox_id(id)
    @sandbox_id = id
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

  def send_verified #same functionality as send_verification
    @target.verified
  end

  def send_ipn(ipn)
    @target.send_ipn(ipn)
  end

  def test_mode_on
    set_test_mode(TEST_ON)

  end

  def test_mode_off
    set_test_mode(TEST_OFF)
  end

  private

  def set_test_mode(mode)
    RestClient.post(@server_url, { params: { my_id: @sandbox_id, test_mode: mode
    } })
  end

end
