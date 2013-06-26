require 'rest_client'
class Poller

  def initialize(router, server_url)
    @router = router
    @server_url = server_url
  end

  def retrieve_ipn
    computer_id = @router.ip_address
    RestClient.get(@server_url, computer_id)
  end

  def poll_for_ipn(time=5.0)
    loop do
      ipn = retrieve_ipn
      @router.forward_ipn ipn unless (ipn.nil?)
      sleep time
    end
  end


end