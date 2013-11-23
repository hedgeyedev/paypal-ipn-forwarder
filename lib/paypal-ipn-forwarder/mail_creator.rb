require_relative 'load_config'
require_relative 'host_info'

module PaypalIpnForwarder

  # Create the email contents.  If running under Linux, then add special additional
  # contents needed by the Linux mailer.
  class MailCreator

    def initialize(host=HostInfo.new)
      @host = host
    end

    def create(mail)
      config = Hash.new
      unless @host.running_on_osx?
        configure_for_linux config
      end
      config.merge(mail)
    end

    private

    def configure_for_linux(config)
      config[:via_options] = { :address => '0.0.0.1', :openssl_verify_mode => 'none' }
      config[:via]         = :smtp
    end

  end
end
