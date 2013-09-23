require_relative 'load_config'

module PaypalIpnForwarder
  class MailCreator

    def initialize(set_test_mode=false)
      content = LoadConfig.new(set_test_mode)
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
end
