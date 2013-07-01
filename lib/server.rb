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
    @last_poll_time = content.last_poll_time.clone
    @unexpected_poll_time = content.@unexpected_poll_time.clone
    @email_map = content.email_map.clone
  end

  def ipn
    @ipn
  end

  def receive_poll_from_computer(paypal_id)
  end

  def send_ipn(paypal_id)
    if (ipn_present?(paypal_id))
      ipn = queue_pop(paypal_id)
      ipn
    end
  end

  def send_verification
    "VERIFIED"
  end

  def paypal_id(ipn)
    params = CGI::parse(ipn)
    params["receiver_id"].first
  end

  def paypal_id(paypal_id)
    @map[paypal_id]
  end

  def receive_ipn(ipn=nil)
    paypal_id = paypal_id(ipn)
    unless (recurring?(ipn) || !computer_online?(paypal_id))
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
        @last_poll_time = Time.now
      end
    elsif (params['test_mode']== 'off')
      @computers_testing[id] = false
      @queue_map[id] = nil
      @last_poll_time = nil
    end
  end

  def computer_online?(id)
    @computers_testing[id]
  end

  def queue_identify(paypal_id, method_called_by)
    queue = @queue_map[paypal_id]
    if(queue.nil?)
      no_computer_queue(method_called_by)
    end
    queue
  end

  def no_computer_queue(method_called_by, paypal_id)
    @email = {
        :to => @email_map[paypal_id],
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
    queue = queue_identify(paypal_id, 'queue push')
    unless(queue.nil?)
      queue.push(ipn)
    end
    queue
  end
  
  def queue_size(paypal_id)
    queue = @queue_map[paypal_id]
    if(queue == nil)
      0
    else
      queue.size
    end
  end

  def queue_pop(paypal_id)
    queue = queue_identify(paypal_id, 'queue pop')
    unless(queue.nil?)
      queue.pop
    end
  end

  def ipn_present?(paypal_id)
    queue_size(paypal_id) >= 1
  end

  def receive_ipn_response(ipn_response)
    paypal_id = paypal_id(ipn_response)
    store_ipn_response(paypal_id)
  end

  def store_ipn_response(paypal_id)
    @ipn_response[paypal_id] = "VERIFIED"
  end

  def ipn_response_present?(paypal_id)
    ipn_response = @ipn_response[paypal_id]
    !ipn_response.nil?
  end

  def respond_to_computer_poll(paypal_id)
    @last_poll_time = Time.now
    if(computer_online?(paypal_id))
       unexpected_poll(paypal_id)
    elsif ipn_response_present?(paypal_id)
      send_verification
    else
      send_ipn(paypal_id)
    end
  end

  def unexpected_poll(paypal_id)
    @unexpected_poll_time[paypal_id] = Time.now
    @email = {
        :to => @email_map[paypal_id],
        :from => 'email-proxy-problems@superbox.com',
        :subject => 'Unexpected poll from your developer machine',
        :body => 'Your computer made an unexpected poll on the Superbox IPN forwarder. The poll occurred before test mode was turned on'
    }
    mailsender = MailSender.new
    mailsender.send(@email)
  end

  def recurring?(ipn)
    params = CGI::parse(ipn)
    recurring = params["recurring"].first
    !recurring.nil?
  end


end
