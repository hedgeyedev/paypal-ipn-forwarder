class Computer

  # Send an HTTP request to the target computer
  # @param [String] ipn the XML string from PayPal to send to the target computer
  # @param [String] the response from the target computer
  def send_ipn(ipn)
    "a response"
  end
  def receive_ipn(ipn)
    @ipn = ipn
  end
  def ipn
    @ipn
  end

end
