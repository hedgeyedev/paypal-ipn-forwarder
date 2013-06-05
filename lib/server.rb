require 'cgi'
require_relative 'map'

class Server

  def initialize(ipn=nil)
    @ipn = ipn unless ipn.nil?
    @map = {
          'gpmac_1231902686_biz@paypal.com' => 'developer_one',
          'paypal@gmail.com' => 'developmentmachine:9999/'
          }
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
    #@map[paypal_id]
   instance = Map.new
   instance.computer(paypal_id)
  end

end
