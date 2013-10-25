require 'cgi'
require 'sinatra/base'
require 'yaml'
require 'awesome_print'

require_relative 'load_config'
require_relative 'mail_sender'
require_relative 'server_poll_checker'
require_relative '../lib/server_ipn_reception_checker'



class Server

  PROCESS_ID_IPN_CHECKER = '.process_id_for_ipn_checker'
  POLL_CHECKER_PROCESS_ID = '.process_id_for_poll_checker'

  def initialize(test=nil)
    @test_mode = !test.nil?
    LoadConfig.set_test_mode(!test.nil?)
    content = LoadConfig.new
    @computers_testing = content.computer_testing.clone
    @queue_map = content.queue_map.clone
    @email_map = content.email_map.clone
    @poll_checker_instance = content.poll_checker_instance.clone
    @ipn_reception_checker_instance = Hash.new
  end

  def paypal_id(ipn)
    params = CGI::parse(ipn)
    params['receiver_email'].first
  end

  def receive_ipn(ipn=nil)
    paypal_id = paypal_id(ipn)
    if (computer_online?(paypal_id) && !ipn.nil?)
      queue_push(ipn)
      paypal_id = paypal_id(ipn)
      @ipn_reception_checker_instance[paypal_id].ipn_received
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
    @queue_map[id] = Queue.new
    email_mapper(id, params['email'])

    #the following line is needed in case the sandbox is a new one.
    @poll_checker_instance[id] = ServerPollChecker.new(self) if @poll_checker_instance[id].nil?
    @poll_checker_instance[id].record_poll_time(id)

    @ipn_reception_checker_instance[id] = ServerIpnReceptionChecker.new(self, id)

    unless @test_mode
      @ipn_reception_checker_instance[id].check_ipn_received
      @process_id =  fork do

        Signal.trap("HUP") do
          @poll_checker_instance[id].loop_boolean = false
        end

        @poll_checker_instance[id].check_testing_polls_occurring(id)
      end

      File.write(POLL_CHECKER_PROCESS_ID+'_'+id, @process_id, nil, nil)
      Process.detach(@process_id)
    end
  end

  def cancel_test_mode(id)
    @computers_testing[id] = false
    @queue_map[id] = nil
    process_id_ipn_checker = File.read(PROCESS_ID_IPN_CHECKER+'_'+id).to_i
    process_id_poll_checker = File.read(POLL_CHECKER_PROCESS_ID+'_'+id).to_i
    Process.kill("HUP", process_id_ipn_checker) unless @test_mode || @ipn_reception_checker_instance[id].ipn_received?
    Process.kill("HUP", process_id_poll_checker) unless @test_mode
    @ipn_reception_checker_instance[id] = nil
    File.delete(PROCESS_ID_IPN_CHECKER+'_'+id)
    File.delete(POLL_CHECKER_PROCESS_ID+'_'+id)
  end

  def same_sandbox_being_tested_twice?(id, params)
    params['email'].first != @email_map[id].first
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
    @poll_checker_instance[id].email_developer_incomplete_request(email, test_mode, id)
  end

  def email_map
    @email_map
  end

  def ipn_valid?(ipn)
    !ipn.nil? && ipn.length > 0 && (ipn =~ /(VERIFIED|INVALID)/) != 0
  end

  def printo(vars)
    id = paypal_id(vars)
    puts vars +'\n'
    puts id

  end

end