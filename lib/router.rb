require 'rest_client'
class Router

  def initialize(cms=nil)
    @cms = cms
  end

  def send_ipn(ipn)
   @responce = @cms.send_ipn(ipn)
  end

  def send_verified
  end

  def receive_ipn_response
  end

  def poll_for_ipn_response
     url = 'http://superbox.hedgeye.com:8810/ipn-response'
     ipn_response = RestClient.get url
     if(ipn_response == "VERIFIED")
       send_verification
     end
  end

  def send_verification
    @cms.receive_verification
  end

end