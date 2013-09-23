module PaypalIpnForwarder
  module HostInfo

    def running_on_osx
      RbConfig::CONFIG['host_os'] =~ /darwin/
    end

  end
end
