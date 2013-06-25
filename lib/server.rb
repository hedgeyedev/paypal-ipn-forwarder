require 'cgi'
require 'sinatra/base'
require 'yaml'

require_relative 'computer'

class Server
  MAP = {
        'gpmac_1231902686_biz.api@paypal.com' => 'developer_one',
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

    COMPUTER_MAP = {
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
    if(ipn_present?)
      ipn = queue_pop
      ipn
    end
  end

  def send_verification
    "VERIFIED"
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
    unless(recurring?(ipn))
      @ipn = ipn unless ipn.nil?
    end
  end

  def ipn_response(ipn)
    response = 'cmd=_notify-validate&' + ipn
    response
  end

  def computer_testing(id)
    computer_id = COMPUTER_MAP[id]
    unless(computer_online?(id))
      COMPUTERS_TESTING[computer_id] = true
    else
      COMPUTERS_TESTING[computer_id] = false
    end
  end

  def computer_online?(id)
    computer = COMPUTER_MAP[id]
    COMPUTERS_TESTING[computer]
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

  def ipn_present?
    queue_size >= 1
  end

  def receive_ipn_response(ipn_response)
    paypal_id = paypal_id(ipn_response)
    computer_id = computer_id(paypal_id)
    store_ipn_response(computer_id)
  end

  def store_ipn_response(computer_id)
    IPN_RESPONSE[computer_id] = "VERIFIED"
  end

  def ipn_response_present?(computer_id)
    ipn_response = IPN_RESPONSE[computer_id]
    !ipn_response.nil?
  end

  def send_response_to_computer(computer_id)
    if ipn_response_present?(computer_id)
      send_verification
    else
      send_ipn
    end
  end

  def recurring?(ipn)
    params = CGI::parse(ipn)
    recurring = params["recurring"].first
    unless(recurring == "")
      true
    else
      false
    end
  end

  def load_computer_map
    content = YAML::load_file(File.expand_path("../../config/ip.yml", __FILE__))
    content.each_key do |key, value|
      value = content[key]
      COMPUTER_MAP[value] = key
    end
  end

end
