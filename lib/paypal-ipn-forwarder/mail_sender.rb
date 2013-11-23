require 'pony'
require_relative 'mail_creator'

module PaypalIpnForwarder
  class MailSender

    def initialize(mail_generator=MailCreator.new)
      @mail_generator = mail_generator
    end

    def send_mail(to, subject, body)
      mail = param_definer(to, subject, body)
      Pony.mail(@mail_generator.create(mail))
    end

    private

    def param_definer(to, subject, body)
      {
          :to      => to,
          :from    => 'email-proxy@paypal-ipn-forwarder.com',
          :subject => subject,
          :body    => body
      }
    end

  end
end
