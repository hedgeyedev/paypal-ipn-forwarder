require_relative 'load_config'
require_relative 'host_info'

module PaypalIpnForwarder
  class MailCreator

    attr_reader :config

    def initialize
      @config = Hash.new
      unless PaypalIpnForwarder::HostInfo.running_on_osx?()
        configure_for_linux
      end
    end

    def create(mail)
      @config.merge(mail)
    end

    private

    def configure_for_linux
      @config[:via_options] = @config[:via_options]
      @config[:via]         = @config[:via]
    end

  end
end
