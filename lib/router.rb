require 'rest_client'
require_relative 'poller'
class Router

  def initialize(target=nil)
    @target = target
    @killing = false
    #router_handler.test_mode_on
  end

  def server_mock(server=nil)
    @server = server
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

  def test_mode_on
    url = 'http://superbox.hedgeye.com:8810/test/'
    message = ip_address
    RestClient.post url, message
    @server.computer_online(ip_address)
  end

  def test_mode_off
    url = 'http://superbox.hedgeye.com:8810/test/'
    message = ip_address
    RestClient.post url, message
  end

  def ip_address #from: http://claudiofloreani.blogspot.com/2011/10/ruby-how-to-get-my-private-and-public.html
    Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
  end

end
