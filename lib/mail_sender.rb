class Mail_Sender

  def create(mail)
    @email_creator(default:Send_Grid_Mail_Creater.new)
    @email_content = @email_creator.create(mail)
  end

  def send_email
    Pony.mail(@email_content)
  end

end
