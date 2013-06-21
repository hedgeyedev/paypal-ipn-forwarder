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

end
