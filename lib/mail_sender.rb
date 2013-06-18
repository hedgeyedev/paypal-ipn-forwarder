class MailSender

  def create(mail, gateway=nil)
    @email_creator = gateway || SendGridMailCreator.new
    @email_content = @email_creator.create(mail)
  end

  def send_email
    Pony.mail(@email_content)
  end

end
