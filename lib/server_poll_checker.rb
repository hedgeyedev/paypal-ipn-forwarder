require_relative 'load_config'
require_relative '../lib/mail_sender'

class ServerPollChecker

  attr_accessor :last_unexpected_poll

  def initialize(test=nil)
    LoadConfig.set_test_mode(!test.nil?)
    @content = LoadConfig.new
    @last_unexpected_poll = Time.now - 2*24*60*60
  end

  def poll_time(paypal_id, time=Time.now)
    if (@last_unexpected_poll + 24*60*60 <=> time) == -1
      send_email(paypal_id)
      @last_unexpected_poll = time
    end
  end

  def send_email(paypal_id)
    @email_map = @content.email_map
    unless @email_map[paypal_id].nil?
      to = @email_map[paypal_id]
      subject = 'Unexpected poll from your developer machine'
      body = "Your computer made an unexpected poll on the Superbox IPN forwarder. The poll occurred before test mode was turned on. The sandox id is #{paypal_id}"
      mailsender = MailSender.new
      mailsender.send(to, subject, body)
    else
      @email_map.each_value { |value|
        to = value
        subject = "Unexpected poll from a developer machine"
        body = "A computer made an unexpected poll on the Superbox IPN forwarder. The poll occurred before test mode was turned on. The sandox id is #{paypal_id}"
        mailsender = MailSender.new
        mailsender.send(to, subject, body)
      }

    end
  end

end