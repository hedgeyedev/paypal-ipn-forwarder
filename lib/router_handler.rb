require 'rest_client'
class RouterHandler

  def initialize(router)
    @router = router
  end

  def retrieve_ipn
     url = 'http://superbox.hedgeye.com:8810/'
     #url = 'localhost:8810/ipn-response'
     message = ip_address
     ipn = RestClient.get url, message
     ipn
  end

  def ip_address #from: http://claudiofloreani.blogspot.com/2011/10/ruby-how-to-get-my-private-and-public.html
    Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
  end

  def test_mode_on
    url = 'http://superbox.hedgeye.com:8810/test/'
    message = ip_address
    RestClient.post url, message
    @router.poll_for_ipn
    @server.computer_online(ip_address)
  end

  def test_mode_off
    url = 'http://superbox.hedgeye.com:8810/test/'
    message = ip_address
    RestClient.post url, message
    @router.kill_poll
  end

end