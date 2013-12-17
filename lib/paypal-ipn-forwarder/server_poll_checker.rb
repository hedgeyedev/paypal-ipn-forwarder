require_relative 'load_config'
require_relative 'mail_sender'

module PaypalIpnForwarder
  class ServerPollChecker

    attr_accessor :last_unexpected_poll, :loop_boolean

    def initialize(server, is_test_mode=false)
      @content = LoadConfig.new(is_test_mode)
      #places variables to 2 day before creation of class instance
      @last_unexpected_poll = Time.now - 2*24*60*60
      @last_incomplete_poll = Time.now - 2*24*60*60
      @last_poll_time = @content.last_poll_time.clone
      @server = server

    end

    def record_poll_time(paypal_id, time=Time.now)
      @last_poll_time[paypal_id] = time
    end

    def last_poll_time(paypal_id)
      @last_poll_time[paypal_id]
    end

    def unexpected_poll_time(paypal_id, time=Time.now)
      if(@last_unexpected_poll + 24*60*60 <= time)
        send_email(paypal_id, MailSender::POLL_BEFORE_TEST_MODE_ON_ERROR)
        @last_unexpected_poll = time
      end
    end

    def send_email(paypal_id, body)
      @email_map = @server.email_map
      unless @email_map[paypal_id].nil?
        to = @email_map[paypal_id]
        subject = MailSender.build_subject_line(paypal_id)
        body = body + HAPPENING_ONLY_TO_YOU
        mailsender = MailSender.new
        mailsender.send_mail(to, subject, body)
      else
        @email_map.each_value { |value|
          to = value
          subject = MailSender.build_subject_line(paypal_id)
          body = body
          mailsender = MailSender.new
          mailsender.send_mail(to, subject, body)
        }
      end
    end

    def check_testing_polls_occurring(paypal_id, time=@content.no_polling_time_before_email)
      sleep_time = @content.poll_checking_interval_seconds.to_i
      @loop_boolean = true
      @last_email_sent = last_poll_time(paypal_id)
      loop do
        sleep sleep_time
        break unless @loop_boolean
        if (@last_email_sent <=> Time.now - time) == -1 && (last_poll_time(paypal_id) <=> Time.now - time) == -1
          body = "Test mode has been turned on for sandbox with id: #{paypal_id} but no polling has occurred for it in an hour. Please address this issue.
        A simple way is to turn testing off by running 'ruby stop_paypal' in the paypal ipn forwarder gem"
          send_email(paypal_id, body)
          @last_email_sent = Time.now
          @server.cancel_test_mode(paypal_id) if (last_poll_time(paypal_id) <=> Time.now - 3*time) == -1
          break if (last_poll_time(paypal_id) <=> Time.now - 3*time) == -1
        end
      end
    end

    def email_developer_incomplete_request(email, test_mode, id, time=Time.now)
      to = email
      subject = 'Your computer is polling the Superbox IPN forwarder but is missing information. No IPN will be retrieved'
      body = "Your development computer is polling the Superbox IPN forwarder.
    Here is the information it is providing:\nemail:#{email}\ntest_mode:#{test_mode}\nid:#{id}\n
    One of those fields is blank. Please fix this problem and start polling again."

      if (@last_incomplete_poll + 60*60 <=> time) == -1
        @last_incomplete_poll = Time.now
        mailsender = MailSender.new
        mailsender.send_mail(to, subject, body)
      end
    end
  end
end
