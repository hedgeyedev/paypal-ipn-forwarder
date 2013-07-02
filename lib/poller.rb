require 'rest_client'
class Poller

  def initialize(router, server_url)
    @router = router
    @dev_id = server_url
    @sandbox_id = @router.sandbox_id
  end

  def retrieve_ipn
    #computer_id = @router.ip_address
    RestClient.get(@dev_id, @sandbox_id)
  end

  #caller is for testing-only
  def poll_for_ipn(caller=nil)
    loop do
      ipn = retrieve_ipn
      @router.forward_ipn ipn unless (ipn.nil?)
      sleep @time_in_sec
      break unless (caller.nil? || caller.keep_polling?)
    end
  end

  attr_writer :time_in_sec




end