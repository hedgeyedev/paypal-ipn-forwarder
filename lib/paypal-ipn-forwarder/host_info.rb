module PaypalIpnForwarder
  class HostInfo

    # @return [Boolean] true if running under OSX; false if running under Linux or (gasp!) Windows
    def running_on_osx?
      !(RbConfig::CONFIG['host_os'] =~ /darwin/).nil?
    end

  end
end
