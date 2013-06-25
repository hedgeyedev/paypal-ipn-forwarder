require 'rest_client'
require_relative 'router_handler'
class Router

  def initialize(target=nil)
    @target = target
    #router_handler.test_mode_on
    @killing = false
    @router_handler = RouterHandler.new(self)
  end

  def server_mock(server=nil)
    @server = server
  end

  def destroy
    @router_handler.test_mode_off
  end

  def poll_for_ipn
    loop do
      break if @killing
      ipn = @router_handler.retrieve_ipn
      forward_ipn ipn unless(ipn.nil?)
      sleep 5.0
    end
  end

  def kill_poll
    @killing = true
  end

  def forward_ipn(ipn)
      if(ipn == "VERIFIED")
         send_verified
      else
        send_ipn(ipn)
      end
    end

  def send_verified#same functionality as send_verification
    @target.verified
  end

  def send_ipn(ipn)
   @responce = @target.send_ipn(ipn)
  end

end
