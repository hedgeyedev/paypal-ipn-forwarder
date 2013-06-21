require 'cgi'
require 'sinatra/base'
require 'rest_client'

require_relative 'computer'

class Server
  MAP = {
        'gpmac_1231902686_biz@paypal.com' => 'developer_one',
        'paypal@gmail.com' => 'developmentmachine:9999/'
        }
  COMPUTERS_TESTING = {
      'developer_one' => false,
      'developmentmachine:9999/' => false
  }
  IPN_RESPONSE = {
    'developer_one' => nil,
    'developmentmachine:9999/' => nil
  }

  def ipn
    @ipn
  end

  def create_queue
    @queue = Queue.new
  end

  def initialize(ipn=nil)
    @ipn = ipn unless ipn.nil?
  end

  def send_ipn
    #@comp_id = id
    computer = Computer.new
    computer.send_ipn @ipn
  end

  def paypal_id(ipn)
    params = CGI::parse(ipn)
    params["receiver_email"].first
  end

  def computer_id(paypal_id)
      MAP[paypal_id]
  end

  # FIXME: This didn't merge cleanly; bet it doesn't work.
  def receive_ipn(ipn=nil)
    @ipn = ipn unless ipn.nil?

    #changes from scott: break tests and unsure of their significance
    #response = IpnResponse.new(@ipn)
    #response.success = 'successful' # again, find out what PayPal _really_ wants
    #response
  end

  def computer_online(id)
    COMPUTERS_TESTING[id] = true
  end

  def computer_online?(id)
    COMPUTERS_TESTING[id]
  end

  def computer_offline(id)
    COMPUTERS_TESTING[id] = false
  end

  def queue_push(ipn)
    @queue.push(ipn)
  end

  def queue_size
    @queue.size
  end

  def queue_pop
    @queue.pop
  end

  def receive_ipn_response(ipn_response)
    paypal_id = paypal_id(ipn_response)
    computer_id = computer_id(paypal_id)
    store_ipn_response(computer_id, ipn_response)
  end

  def store_ipn_response(computer_id, ipn_response)
    IPN_RESPONSE[computer_id] = "VERIFIED"
  end

  def ipn_response_present?(computer_id)
    ipn_response = IPN_RESPONSE[computer_id]
    IPN_RESPONSE[computer_id] = nil
    ipn_response
  end

end
