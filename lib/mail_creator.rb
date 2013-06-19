require 'yaml'

class MailCreator

  def create(mail)
    load_yml("_test")# needs to feed in no params in the prod version
    create_email
    @email = @config.clone
    combine_params(mail)
    @config.clone
    @email
  end

  def create_email
    @email = Hash.new
  end

  def load_yml(dev_version=nil)
    @config = YAML::load_file(File.expand_path("../../config/configure#{dev_version}.yml", __FILE__))
  end

  def combine_params(mail)
    mail.each_key do |key|
      @email[key] = mail[key]
    end
    @email
  end

end
