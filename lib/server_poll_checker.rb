require_relative 'load_config'
require_relative '../lib/mail_sender'
require 'timecop'

class ServerPollChecker

  attr_accessor :last_unexpected_poll

  def initialize(server, test=nil)
    LoadConfig.set_test_mode(!test.nil?)
    @content = LoadConfig.new
    @last_unexpected_poll = Time.now - 2*24*60*60
    @last_poll_time = @content.last_poll_time.clone
    @server = server

  end

  def record_poll_time(paypal_id)
    @last_poll_time[paypal_id] = Time.now
  end

  def unexpected_poll_time(paypal_id, time=Time.now)
    if (@last_unexpected_poll + 24*60*60 <=> time) == -1
      body = "Your computer made an unexpected poll on the Superbox IPN forwarder. The poll occurred before test mode was turned on. The sandox id is #{paypal_id}."
      send_email(paypal_id, body)
      @last_unexpected_poll = time
    end
  end

  def send_email(paypal_id, body)
    @email_map = @content.email_map
    unless @email_map[paypal_id].nil?
      to = @email_map[paypal_id]
      subject = "A problem occured on the IPN proxy with sandbox #{paypal_id}"
      body = body + 'This problem is happening on a superbox belonging to you so this email was only sent to you. Please address it'
      mailsender = MailSender.new
      mailsender.send(to, subject, body)
    else
      @email_map.each_value { |value|
        to = value
        subject = "A problem occured on the IPN proxy with sandbox #{paypal_id}"
        body = body
        mailsender = MailSender.new
        mailsender.send(to, subject, body)
      }
    end
  end

  def check_testing_polls_occurring(paypal_id, time=@content.poll_checking_interval_seconds)
    loop do
      sleep time
      break if !@server.computer_online?(paypal_id)
      if (@last_poll_time[paypal_id] <=> Time.now - time) == -1 || @last_poll_time[paypal_id].nil?
        body = "Test mode has been turned on for sandbox with id: #{paypal_id} but no polling has occurred for it in an hour. Please address this issue."
        send_email(paypal_id, body)
        @server.computer_testing({'my_id' => paypal_id, 'test_mode' => 'off'}) if (@last_poll_time[paypal_id] <=> Time.now - 3*time) == -1
        break if (@last_poll_time[paypal_id] <=> Time.now - 3*time) == -1
      end
   end
  end

end