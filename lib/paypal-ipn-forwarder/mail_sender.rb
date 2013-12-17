require 'pony'
require_relative 'mail_creator'

module PaypalIpnForwarder

  EMAIL = 'email-proxy@paypal-ipn-forwarder.com'
  POLL_BEFORE_TEST_MODE_ON_ERROR = 'Your computer polled the PayPal IPN forwarder before test mode was turned on.'
  HAPPENING_ONLY_TO_YOU = <<EOF
  This problem is happening on a PayPal sandbox belonging to you so this email was only sent to
you. Please address it'
EOF

  class MailSender

    def initialize(mail_generator=MailCreator.new)
      @mail_generator = mail_generator
    end

    def send_mail(to, subject, body)
      mail = param_definer(to, subject, body)
      pony_email = @mail_generator.create(mail)
      Pony.mail(pony_email)
    end

    def self.build_subject_line(sandbox_id)
      "A problem occurred on the IPN proxy with sandbox #{sandbox_id}"
    end

    def self.error_polled_before_test_mode_on(sandbox_id)
      POLL_BEFORE_TEST_MODE_ON_ERROR
    end

    private

    def param_definer(to, subject, body)
      {
          :to      => to,
          :from    => EMAIL,
          :subject => subject,
          :body    => body
      }
    end

  end
end
