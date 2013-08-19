require_relative 'load_config'
class RouterClient

  def initialize(test=nil)
    LoadConfig.set_test_mode(test)
    @config = LoadConfig.new
    @server_url = @config.server_url
    @server_url += 'test'
    @final_destination_url = @config.final_destination_url
  end

  def send_ipn(ipn)
    RestClient.post @final_destination_url, ipn
  end

  def set_test_mode(mode, email, sandbox_id)
    RestClient.post(@server_url,  { 'sandbox_id' => sandbox_id, 'test_mode' => mode, 'email' => email
     })
  end

end
