require 'pony'
require_relative 'mail_creator'
class MailSender

  def send(to, subject, body)
    mail = param_definer(to, subject, body)
    create(mail)
    send_email
  end

  def create(mail, mail_generator=MailCreator.new)
    @email_creator = mail_generator
    @email_content = @email_creator.create(mail)
    @email_content
  end

  def send_email
    Pony.mail(@email_content)
  end

  def param_definer(to, subject, body)
    email = {
        :to => to,
        :from => 'email-proxy@paypal_ipn_forwarder.com',
        :subject => subject,
        :body => body
    }
  end

end
