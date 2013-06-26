class MailCreator

  def initialize
    LoadConfig.set_test_mode
    content = LoadConfig.new
    @config = content.mail_creator
  end
  end
  def create(mail)
    load_yml
    create_email_hash
    @email = @config.clone
    combine_params(mail)
    @config.clone
    @email
  end

  def create_email_hash
    @email = Hash.new
  end

  def combine_params(mail)
    mail.each_key do |key|
      @email[key] = mail[key]
    end
    @email
  end

end
