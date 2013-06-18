require 'yaml'

class SendGridMailCreator

  def create(mail)
    @mail = mail
    #email = Hash.new
    load_yml
    create_email
    @email = @config.clone
    combine_params(mail)
    @config.clone
    @email
  end

  def create_email
    @email = Hash.new
  end

  def load_yml
    @config = YAML::load_file(File.expand_path("../../config/configure.yml", __FILE__))
  end

  def combine_params(mail)
    mail.each_key do |key|
      @email[key] = mail[key]
    end
    @email
  end

end
