require_relative 'load_config'
require_relative 'server'
require_relative 'mail_sender'

module PaypalIpnForwarder
  class ServerIpnReceptionChecker

    PROCESS_ID_IPN_CHECKER = '.process_id_for_ipn_checker'

    def initialize(server, paypal_id, is_test_mode=false)
      @content = LoadConfig.new(is_test_mode)
      @server = server
      @paypal_id = paypal_id
      @time_test_started = Time.now
      @time_before_email = @content.no_ipn_time_before_notification
      @ipn_received = false

    end

    def check_ipn_received
      @process_id = fork do

        Signal.trap('HUP') do
          @ipn_received = true
        end

        verify_ipn_received

      end
      Process.detach(@process_id)
      File.write(ServerIpnReceptionChecker::PROCESS_ID_IPN_CHECKER + '_' + @paypal_id, @process_id, nil, nil)
    end

    def verify_ipn_received(time=1.0)
      loop do
        if Time.now >= @time_test_started + @time_before_email
          send_email_that_no_ipn_received
          break
        end
        break if @ipn_received
        sleep time
      end
    end

    def send_email_that_no_ipn_received
      email_map = @server.email_map
      to = email_map[@paypal_id]
      subject = "No IPNs are being received from paypal sandbox ##{@paypal_id} on the paypal IPN forwarder"
      body = "Test mode has been turned on for sandbox with id: #{@paypal_id} but no IPN has been received for it in an 9 minutes.
There most likely is an issue with the paypal sandbox."
      mailsender = MailSender.new
      mailsender.send_mail(to, subject, body)
    end

    def ipn_received
      @ipn_received = true
    end

    def ipn_received?
      @ipn_received
    end
  end
end
