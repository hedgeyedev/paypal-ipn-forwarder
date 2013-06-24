require 'rest_client'
class Router

  def initialize(target=nil)
    @target = target
  end

  def send_ipn(ipn)
   @responce = @target.send_ipn(ipn)
  end

  def send_verified
    @target.verified
  end

  def poll_for_ipn_response_verification
     url = 'http://superbox.hedgeye.com:8810/ipn-response'
     ipn_response = RestClient.get url
     if(ipn_response == "VERIFIED")
       send_verification
     end
  end

  def send_verification
    @target.receive_verification
  end

  def test_mode_on
    url = 'http://superbox.hedgeye.com:8810/ipn-response'
    message = "this machine has started testing"
    #RestClient.post url,
    #TODO:figure out how to identify each computer. i.e. how does computer specify itself.
    #currently through email and id which is based on email
  end

  def test_mode_off
    url = 'http://superbox.hedgeye.com:8810/ipn-response'
    message = "this machine has ended testing"
    #RestClient.post url,
    #TODO:figure out how to identify each computer. i.e. how does computer specify itself.
    #currently through email and id which is based on email
  end
end