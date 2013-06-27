require_relative 'load_config'

class MailCreator

  def initialize(test=nil)
    LoadConfig.set_test_mode(!test.nil?)
    content = LoadConfig.new
    @config = content.mail_creator
  end
  def create(mail)
    create_email
    @email = @config.clone
    combine_params(mail)
    @config.clone
    @email
  end

  def create_email
    @email = Hash.new
  end

  def combine_params(mail)
    mail.each_key do |key|
      @email[key] = mail[key]
    end
    @email
  end

end
