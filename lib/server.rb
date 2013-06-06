require 'cgi'
require 'sinatra'
require 'rest_client'

class Server
   MAP = {
          'gpmac_1231902686_biz@paypal.com' => 'developer_one',
          'paypal@gmail.com' => 'developmentmachine:9999/'
          }
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
      MAP[paypal_id]
  end

  #post '/*' do
    #@ipn = params[:splat].first
    #url = “https://www.sandbox.paypal.com/cgi-bin/webscr”
    #RestClient.post url, @ipn
  #end

end
