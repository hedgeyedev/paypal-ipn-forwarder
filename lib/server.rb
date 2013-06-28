require 'cgi'
require 'sinatra/base'
require 'yaml'

require_relative 'load_config'
require_relative 'mail_sender'

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

  def send_ipn(computer_id)
    if (ipn_present?(computer_id))
      ipn = queue_pop(computer_id)
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
      queue_push(ipn)
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

  def queue_identify(computer_id, method_called_by)
    queue = @queue_map[computer_id]
    if(queue == nil)
      no_computer_queue(method_called_by)
    end
    queue
  end

  def no_computer_queue(method_called_by)
    @email = {
        :to => developer_email,
        :from => 'email-proxy-problems@superbox.com',
        :subject => 'There is no queue on the Superbox IPN forwared',
        :body => 'on the Superbox IPN forwarder, there is no queue set up for this function: "' + method_called_by +'" for your developer_id'
    }
      mailsender = MailSender.new
      mailsender.send(@email)
  end

  def developer_email
    'dmitri.ostapenko@gmail.com'
    #needs to be written. Need to create new hash
  end


  def queue_push(ipn)
    paypal_id = paypal_id(ipn)
    computer_id = computer_id(paypal_id)
    queue = queue_identify(computer_id, 'queue push')
    unless(queue.nil?)
      queue.push(ipn)
    end
    queue
  end

  def queue_size(computer_id)
    queue = @queue_map[computer_id]
    queue.size
  end

  def queue_pop(computer_id)
    queue = queue_identify(computer_id, 'queue pop')
    unless(queue.nil?)
      queue.pop
    end
  end

  def ipn_present?(computer_id)
    queue_size(computer_id) >= 1
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
      send_ipn(computer_id)
    end
  end

  def recurring?(ipn)
    params = CGI::parse(ipn)
    recurring = params["recurring"].first
    !recurring.nil?
  end
end
