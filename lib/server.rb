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
    @computers_testing = content.computer_testing.clone
    @queue_map = content.queue_map.clone
    @email_map = content.email_map.clone
    @poll_checker_instance = content.poll_checker_instance.clone
    @poll_checker_instance.each_value {|key, value|
    value = ServerPollChecker.new(self)
    }
  end

  def paypal_id(ipn)
    params = CGI::parse(ipn)
    params['receiver_id'].first
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

  def computer_online?(id)
    @computers_testing[id]
  end

  def begin_test_mode(id, params)
    @computers_testing[id] = true
    @queue_map[id]     = Queue.new
    email_mapper(id, params['email'])
    #the following line is needed in case the sandbox is a new one.
    @poll_checker_instance[id] = ServerPollChecker.new(self) if @poll_checker_instance[id].nil?
    @poll_checker_instance[id].record_poll_time(id)
    #Im not sure how to implement this. THe method call below has to fork off and be run in the background separately. It checks that
    #polling is happening now that test mode is on. if not, it sends an email to the developer. It will do that every hour three times
    #and then turn off testing mode

    #@poll_checker_instance[id].check_testing_polls_occurring(id)
  end

  def cancel_test_mode(id)
    @computers_testing[id] = false
    @queue_map[id] = nil
  end

  def same_sandbox_being_tested_twice?(id, params)
    params['email'] != @email_map[id]
  end

  def send_conflict_email(paypal_id, email)
    to = @email_map[paypal_id]
    subject = 'You have turned on an already-testing sandbox. IT HAS BEEN TAKEN OFF OF TESTING MODE'
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

  def queue_identify(paypal_id, method_called_by)
    queue = @queue_map[paypal_id]
    email_content_generator(method_called_by, paypal_id) if queue.nil?
    queue
  end

  #TODO: figure out a way to test this
  def email_content_generator(method_called_by, paypal_id)
    to = @email_map[paypal_id]
    subject = 'There is no queue on the Superbox IPN forwarder'
    body = "on the Superbox IPN forwarder, there is no queue set up for this function: #{method_called_by} for your developer_id #{paypal_id}"

      mailsender = MailSender.new
      mailsender.send(to, subject, body)
  end

  def queue_push(ipn)
    paypal_id = paypal_id(ipn)
    queue = queue_identify(paypal_id, 'queue push')
    unless(queue.nil?)
      queue.push(ipn)
    end
  end

  #if the queue does not exist(due to sandbox not being in test mode), then the size of the queue will be 0
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

  def send_ipn_if_present(paypal_id)
    if (ipn_present?(paypal_id))
      ipn = queue_pop(paypal_id)
    end
  end

  def record_computer_poll(paypal_id)
    #a new instance of poll checker needs to be created in case poll is before test mode is turned on
    #and the sandbox is not registered beforehand
    @poll_checker_instance[paypal_id] = ServerPollChecker.new(self) if @poll_checker_instance[paypal_id].nil?
    @poll_checker_instance[paypal_id].record_poll_time(paypal_id)
  end

  def unexpected_poll(paypal_id, time=Time.now)
    @poll_checker_instance[paypal_id].unexpected_poll_time(paypal_id, time)
  end

  def poll_with_incomplete_info(email, test_mode, id)
    @poll_checker_instance[id] = ServerPollChecker.new(self) if @poll_checker_instance[id].nil?
    @poll_checker_instance [id].email_developer_incomplete_request(email, test_mode, id)
  end

end

