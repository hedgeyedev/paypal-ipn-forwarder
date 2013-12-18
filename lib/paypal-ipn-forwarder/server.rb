require 'sinatra/base'
require 'yaml'
require 'awesome_print'

require_relative 'ipn'
require_relative 'load_config'
require_relative 'mail_sender'
require_relative 'server_poll_checker'
require_relative 'server_ipn_reception_checker'


module PaypalIpnForwarder
  class Server

    PROCESS_ID_IPN_CHECKER  = '.process_id_for_ipn_checker'
    POLL_CHECKER_PROCESS_ID = '.process_id_for_poll_checker'

    EMAIL_NO_QUEUE_SUBJECT = 'There is no queue on the PayPal IPN forwarder'

    CONFLICT_EMAIL_BODY = <<EOF
EOF

    attr_reader :developers_email

    def initialize(is_load_test_config=false)
      content                         = LoadConfig.new(is_load_test_config)
      @computers_testing              = content.computer_testing.clone
      @queue_map                      = content.queue_map.clone
      @email_map                      = content.email_map.clone
      @poll_checker_instance          = content.poll_checker_instance.clone
      @developers_email               = content.developers_email
      @is_load_test_config            = is_load_test_config
      @ipn_reception_checker_instance = Hash.new
    end

    # param [Ipn] ipn the PayPal representation of the IPN
    def receive_ipn(ipn)
      if computer_online?(ipn.paypal_id)
        queue_push(ipn)
        @ipn_reception_checker_instance[ipn.paypal_id].ipn_received
      end
    end

    def ipn_response(ipn)
      'cmd=_notify-validate&' + ipn
    end

    def computer_online?(id)
      @computers_testing[id]
    end

    def begin_test_mode(id, params)
      @computers_testing[id] = true
      @queue_map[id]         = Queue.new
      email_mapper(id, params['email'])

      #the following line is needed in case the sandbox is a new one.
      @poll_checker_instance[id] = ServerPollChecker.new(self) if @poll_checker_instance[id].nil?
      @poll_checker_instance[id].record_poll_time(id)

      @ipn_reception_checker_instance[id] = ServerIpnReceptionChecker.new(self, id)

      @ipn_reception_checker_instance[id].check_ipn_received
      @process_id = fork do

        Signal.trap('HUP') do
          @poll_checker_instance[id].loop_boolean = false
        end

        @poll_checker_instance[id].check_testing_polls_occurring(id)
      end

      File.write(POLL_CHECKER_PROCESS_ID+'_'+id, @process_id, nil, nil)
      Process.detach(@process_id)
    end

    def cancel_test_mode(developer_id)
      @computers_testing[developer_id] = false
      @queue_map[developer_id]         = nil
      kill_process_for_filename(PROCESS_ID_IPN_CHECKER+'_'+developer_id)
      kill_pid_from_filename(POLL_CHECKER_PROCESS_ID+'_'+developer_id)
      @ipn_reception_checker_instance[developer_id] = nil
    end

    def kill_pid_from_filename(filename)
      process_id_poll_checker = git_pid_from_file(filename)
      Process.kill('HUP', process_id_poll_checker) if process_id_poll_checker
    end

    def kill_process_for_filename(filename)
      process_id_ipn_checker = git_pid_from_file(filename)
      puts "******** process_id_ipn_checker: '#{process_id_ipn_checker}'"
      Process.kill('HUP', process_id_ipn_checker) if process_id_ipn_checker
    end

    def git_pid_from_file(filename)
      File.exist?(filename) ? File.read(filename).to_i : nil
    end

    def same_sandbox_being_tested_twice?(id, params)
      params['email'] != @email_map[id]
    end

    def send_conflict_email(paypal_id, email)
      to      = @email_map[paypal_id]
      subject = 'You have turned on an already-testing sandbox. IT HAS BEEN TAKEN OFF OF TESTING MODE'
      body    = conflict_email_body(paypal_id, email)

      mailsender = MailSender.new
      mailsender.send_mail(to, subject, body)

      to1  = email
      body = conflict_email_body(paypal_id, to)
      mailsender.send_mail(to1, subject, body)
    end

    def conflict_email_body(paypal_id, email)
      "on the Superbox IPN forwarder, you have turned on an already testing sandbox. The sandbox has the id #{paypal_id}. The sandbox has been taken down from testing mode.
    The other user of the sandbox was #{email}"
    end

    def email_mapper(id, email)
      @email_map[id] = email
    end

    def queue_identify(paypal_id, queue_action)
      queue = @queue_map[paypal_id]
      if queue.nil?
        email_no_queue(queue_action, paypal_id)
      end
      queue
    end

    def email_no_queue(method_called_by, paypal_id)
      to      = @email_map[paypal_id] ? @email_map[paypal_id] : developers_email
      subject = EMAIL_NO_QUEUE_SUBJECT
      body    = email_no_queue_body(method_called_by, paypal_id)

      mailsender = MailSender.new
      mailsender.send_mail(to, subject, body)
    end

    def email_no_queue_body(method_called_by, paypal_id)
      'On the PayPal IPN forwarder, there is no queue set up for the function, \'' +
          method_called_by +
          '\', for your developer_id \'' +
          paypal_id +
          '\''
    end

    # @param [Ipn] ipn
    def queue_push(ipn)
      queue = queue_identify(ipn.paypal_id, 'queue push')
      unless queue.nil?
        queue.push(ipn)
      end
    end

    #if the queue does not exist(due to sandbox not being in test mode), then the size of the queue will be 0
    def queue_size(paypal_id)
      queue = @queue_map[paypal_id]
      (queue.nil?) ? 0 : queue.size
    end

    def queue_pop(paypal_id)
      queue = queue_identify(paypal_id, 'queue pop')
      unless queue.nil?
        queue.pop
      end
    end

    def ipn_present?(paypal_id)
      queue_size(paypal_id) >= 1
    end

    def send_ipn_if_present(paypal_id)
      if ipn_present?(paypal_id)
        queue_pop(paypal_id)
      end
    end

    def record_computer_poll(paypal_id, time=Time.now)
      #a new instance of poll checker needs to be created in case poll is before test mode is turned on
      #and the sandbox is not registered beforehand
      @poll_checker_instance[paypal_id] = ServerPollChecker.new(self) if @poll_checker_instance[paypal_id].nil?
      @poll_checker_instance[paypal_id].record_poll_time(paypal_id, time)
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

    # @param [Ipn] ipn
    def printo(ipn)
      ap ipn
    end

  end
end
