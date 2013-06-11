require 'cgi'
require 'sinatra/base'
require 'rest_client'

require_relative 'computer'

class Server
   MAP = {
          'gpmac_1231902686_biz@paypal.com' => 'developer_one',
          'paypal@gmail.com' => 'developmentmachine:9999/'
          }
  def initialize(ipn=nil)
    @ipn = ipn unless ipn.nil?
  end

  def send_ipn(id)
    @comp_id = id
    computer = Computer.new
    computer.send_ipn @ipn
  end

  def paypal_id
    params = CGI::parse(@ipn)
    params["receiver_email"].first
  end

  def computer_id(paypal_id)
      MAP[paypal_id]
  end

  def receive_ipn(ipn=nil)
    @ipn = ipn unless ipn.nil?
    pay_id = paypal_id
    comp_id = computer_id(pay_id)
    #comp_id.should == "developer_one"
    comp_id
  end

  #post '/?' do
    #@ipn = params[:splat].first
    #url = “https://www.sandbox.paypal.com/cgi-bin/webscr”
    #RestClient.post url, @ipn
  #end

end
