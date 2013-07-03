require 'cgi'
require 'sinatra/base'
require 'yaml'
require 'awesome_print'

require_relative 'load_config'
require_relative 'mail_sender'
require_relative 'server_poll_checker'

class Server


  def initialize(test=nil)
    LoadConfig.set_test_mode(!test.nil?)
    content = LoadConfig.new
    @map = content.sandbox_map.clone
    @computers_testing = content.computer_testing.clone
    @ipn_response = content.ipn_response.clone
    @queue_map = content.queue_map.clone
    @email_map = content.email_map.clone
    @poll_checker_instance = content.poll_checker_instance.clone
    @poll_checker_instance.each_value {|key, value|
    value = ServerPollChecker.new(self)
    }
  end


  def receive_poll_from_computer(paypal_id)
  end

  def send_ipn_if_present(paypal_id)
    #TODO:remove ipn_present and make sure no tests break
    if (ipn_present?(paypal_id))
      ipn = queue_pop(paypal_id)
    end
  end

  def send_verification
    "VERIFIED"
  end

  def paypal_id(ipn)
    params = CGI::parse(ipn)
    params['receiver_id'].first
  end

  def paypal_email_id_map(paypal_email)
      @map[paypal_email]
  end


  def receive_ipn(ipn=nil)
    paypal_id = paypal_id(ipn)
    if (computer_online?(paypal_id) && !ipn.nil?)
      queue_push(ipn)
    end
  end

  def ipn_response(ipn)
    response = 'cmd=_notify-validate&' + ipn
    response
  end

  def computer_testing(params)
    id = params['my_id']
    if params['test_mode'] == 'on'
      if (!computer_online?(id))
        @computers_testing[id] = true
        @queue_map[id] = Queue.new
        email_mapper(id, params['email'])
        #the following line is needed in case the sandbox is a new one.
        @poll_checker_instance[id] = ServerPollChecker.new(self) if @poll_checker_instance[id].nil?
        @poll_checker_instance[id].record_poll_time(id)
        #Im not sure how to implement this. THe method call below has to fork off and be run in the background separately. It checks that
        #polling is happening now that test mode is on. if not, it sends an email to the developer. It will do that every hour three times
        #and then turn off testing mode
        #@poll_checker_instance[id].check_testing_polls_occurring(id)
      elsif params['email'] == @email_map[id]
      else
         send_conflict_email(id, params['email'])
         @computers_testing[id] = false
         @queue_map[id] = nil
      end
    elsif (params['test_mode']== 'off')
      @computers_testing[id] = false
      @queue_map[id] = nil
    end
  end

  def send_conflict_email(paypal_id, email)
    to = @email_map[paypal_id]
    subject = 'You have turned on an already_testing sandbox. IT HAS BEEN TAKEN OFF OF TESTING MODE'
    body = "on the Superbox IPN forwarder, you have turned on an already testing sandbox. The sandbox has the id #{paypal_id}. The sandbox has been taken down from testing mode.
    The other user of the sandbox was #{email}"

    mailsender = MailSender.new
    mailsender.send(to, subject, body)

    to1 = email
    body = "on the Superbox IPN forwarder, you have turned on an already testing sandbox. The sandbox has the id #{paypal_id}. The sandbox has been taken down from testing mode.
    The other user of the sandbox was #{to}"
    mailsender.send(to1, subject, body)
  end


  def email_mapper(id, email)
     @email_map[id] = email
  end

  def computer_online?(id)
    @computers_testing[id]
  end

  def queue_identify(paypal_id, method_called_by)
    queue = @queue_map[paypal_id]
    no_computer_queue(method_called_by) if queue.nil?
    queue
  end

  def email_content_generator(method_called_by, paypal_id)
    to = @email_map[paypal_id]
    subject = 'There is no queue on the Superbox IPN forwared'
    body = "on the Superbox IPN forwarder, there is no queue set up for this function: #{method_called_by} for your developer_id #{paypal_id}"

      mailsender = MailSender.new
      mailsender.send(to, subject, body)
  end

  def developer_email
    'dmitri.ostapenko@gmail.com'
#TODO: this needs to be written
  end

  def queue_push(ipn)
    paypal_id = paypal_id(ipn)
    queue = queue_identify(paypal_id, 'queue push')
    unless(queue.nil?)
      queue.push(ipn)
    end
  end
  
  def queue_size(paypal_id)
    queue = @queue_map[paypal_id]
    if(queue.nil?)
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

  def respond_to_computer_poll(paypal_id, now=Time.now)
    #a new instance needs to be created in case poll is before test mode is turned on and the sandbox is not registered beforhand
    @poll_checker_instance[paypal_id] = ServerPollChecker.new(self) if @poll_checker_instance[paypal_id].nil?
    @poll_checker_instance[paypal_id].record_poll_time(paypal_id)
    if(!computer_online?(paypal_id))
      @poll_checker_instance[paypal_id].poll_time(paypal_id)
    elsif ipn_response_present?(paypal_id)
      send_verification
    else
      send_ipn_if_present(paypal_id)
    end
  end

end

