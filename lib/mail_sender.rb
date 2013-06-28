require 'pony'
require_relative 'mail_creator'
class MailSender

  def send(mail)
    create(mail, nil)
    send_email
  end

  def create(mail, mode, mail_generator=nil)
    @email_creator = mail_generator || MailCreator.new(mode)
    @email_content = @email_creator.create(mail)
    @email_content
  end

  def send_email
    Pony.mail(@email_content)
  end

end
