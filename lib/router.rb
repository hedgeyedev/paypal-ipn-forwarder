require 'rest_client'
require 'socket'
class Router

  def initialize(target=nil)
    @target = target
    test_mode_on
  end

  def destroy
    test_mode_off
  end

  def poll_for_ipn
    loop do
      ipn = retrieve_ipn
      forward_ipn ipn unless(ipn.nil?)
      sleep 5.0
    end
  end

  def kill_poll
  end

  def retrieve_ipn
     url = 'http://superbox.hedgeye.com:8810/ipn-response'
     #url = 'localhost:8810/ipn-response'
     ipn = RestClient.get url
     ipn
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
    url = 'http://superbox.hedgeye.com:8810/ipn-response'
    computer_id = ip_address
    message = "#{computer_id}: this machine has started testing"
    #RestClient.post url,
    #poll_for_ipn
  end

  def test_mode_off
    url = 'http://superbox.hedgeye.com:8810/ipn-response'
    computer_id = ip_address
    message = "#{computer_id}: this machine has ended testing"
    #RestClient.post url, message
    kill_poll
  end

  def ip_address #from: http://claudiofloreani.blogspot.com/2011/10/ruby-how-to-get-my-private-and-public.html
    Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
  end

end