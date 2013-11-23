require 'rspec'
require_relative '../lib/paypal-ipn-forwarder/host_info'

include PaypalIpnForwarder

describe HostInfo do

  context '#running_on_osx?' do

    def osx_for_environment?(rb_config_string)
      old_env = RbConfig::CONFIG['host_os']
      begin
        RbConfig::CONFIG['host_os'] = rb_config_string
        host = HostInfo.new
        host.running_on_osx?
      ensure
        RbConfig::CONFIG['host_os'] = old_env
      end
    end

    it 'should return true when running under OSX' do
      osx_for_environment?('xxx darwin yyy').should be true
    end

    it 'should return false when not running under OSX' do
      osx_for_environment?('xxx zzz yyy').should be false
    end
  end
end
