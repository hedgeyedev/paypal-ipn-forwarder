require 'rest_client'
class Poller

  def initialize(router, server_url, sandbox)
    @router = router
    @server_url = server_url + 'computer_poll'
    !sandbox.nil? ? @sandbox_id = sandbox : @sandbox_id = @router.sandbox_id
  end

  def retrieve_ipn
    RestClient.get @server_url, :params => {'sandbox_id' => @sandbox_id}
  end

  #caller is for testing-only
  def poll_for_ipn(caller=nil)
    loop do
      ipn = retrieve_ipn
      @router.send_ipn ipn unless (ipn.nil?)
      sleep @time_in_sec
      break unless (caller.nil? || caller.keep_polling?)
    end
  end

  attr_writer :time_in_sec

end