require 'rest_client'
class Poller

  PROCESS_FILE_NAME = '.process_id'

  def initialize(router, server_url, sandbox=nil)
    @router = router
    @server_url = server_url + 'computer_poll'
    sandbox.nil? ? @sandbox_id = @router.sandbox_id : @sandbox_id = sandbox
    @ipn_received = false
    @time_polling_started = Time.now

  end

  attr_accessor :time_polling_started

  def retrieve_ipn
    begin
      RestClient.get @server_url, :params => {'sandbox_id' => @sandbox_id}
    rescue SystemCallError
      puts 'There is a problem regarding the connection to the server. A SystemCallError occured. Please check the server is online and that test mode has occurred. Check your inbox in case another developer attempted to turn on test mode for your sandbox'
    rescue StandardError
      puts 'There was an error with the server. THe connection is fine because a StandardError occured and not a SystemCallError. Please run some test and make sure that testing is turned on for your sandbox. Check whether you were testing in two different terminals and the other terminal window turned off testing'
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
    @process_id =  fork do

      verify_ipn_received
      Signal.trap("HUP") do
        @ipn_received = true
      end

    end
    Process.detach(@process_id)
    File.write(Poller::PROCESS_FILE_NAME, @process_id, nil, nil)
  end

  def verify_ipn_received(time=5.0)
    loop do
      sleep time
      if (Time.now <=> @time_polling_started + 60*10) == 1
        puts 'an IPN has still not been received, 10 minutes after testing'
        break
      end
      break if @ipn_received
    end
  end

  attr_writer :time_in_sec
  attr_writer :ipn_received

end