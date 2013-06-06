require 'cgi'
require_relative 'map'

class Server

  def initialize(ipn=nil)
    @ipn = ipn unless ipn.nil?
  end

  def send_ipn
    computer = Computer.new
    computer.send_ipn @ipn
  end

  def paypal_id
    params = CGI::parse(@ipn)
    params["receiver_email"].first
  end

  def computer_id(paypal_id)
   $map.computer(paypal_id)
  end

end
