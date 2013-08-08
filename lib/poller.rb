require 'rest_client'
class Poller

  def initialize(router, server_url, sandbox=nil)
    @router = router
    @server_url = server_url + 'computer_poll'
    sandbox.nil? ? @sandbox_id = @router.sandbox_id : @sandbox_id = sandbox
    @ipn_received = false
  end

  def retrieve_ipn
    begin
      RestClient.get @server_url, :params => {'sandbox_id' => @sandbox_id}
    rescue StandardError
      puts 'the connection to the server is failing please check that the server is online'
    end
  end

  #caller is for testing-only
  def poll_for_ipn(caller=nil)
    loop do
      ipn = retrieve_ipn
      unless (ipn.nil? || ipn == '')
        @router.send_ipn ipn
        @ipn_received = true
      end
      sleep @time_in_sec.to_i
      break unless (caller.nil? || caller.keep_polling?)
    end
  end

  def check_ipn_received

  end

  attr_writer :time_in_sec

end