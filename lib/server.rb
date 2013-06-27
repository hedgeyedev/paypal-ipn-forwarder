require 'cgi'
require 'sinatra/base'
require 'yaml'

require_relative 'load_config'

class Server


  def initialize(test=nil)
    LoadConfig.set_test_mode(!test.nil?)
    content = LoadConfig.new
    @map = content.sandbox_map.clone
    @computers_testing = content.computer_testing.clone
    @ipn_response = content.ipn_response.clone
    @queue_map = content.queue_map.clone
  end

  def ipn
    @ipn
  end

  def send_ipn
    if (ipn_present?)
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
    @map[paypal_id]
  end

  def receive_ipn(ipn=nil)
    unless (recurring?(ipn))
      @ipn = ipn unless ipn.nil?
    end
  end

  def ipn_response(ipn)
    response = 'cmd=_notify-validate&' + ipn
    response
  end

  def computer_testing(params)
    id = params['my_id']
    if (params['test_mode']== 'on')
      unless (computer_online?(id))
        @computers_testing[id] = true
        @queue_map[id] = Queue.new
      end
    elsif (params['test_mode']== 'off')
      @computers_testing[id] = false
      @queue_map[id] = nil
    end
  end

  def computer_online?(id)
    @computers_testing[id]
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
    @ipn_response[computer_id] = "VERIFIED"
  end

  def ipn_response_present?(computer_id)
    ipn_response = @ipn_response[computer_id]
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
    !recurring.nil?
  end
end
