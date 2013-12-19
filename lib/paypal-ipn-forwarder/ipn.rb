require 'sinatra/base'
require_relative 'ipn_generator'

module PaypalIpnForwarder

  # Hold PayPal IPN information in an easily accessible object.
  class Ipn

    attr_reader :ipn_str

    # @param [String] ipn_string the raw IPN string sent to us from PayPal
    def initialize(ipn_string)
      @ipn_str = ipn_string
      @ipn = Rack::Utils.parse_nested_query(ipn_string)
    end

    def self.generate
      @ipn = new IpnGenerator::IPN
    end

    # @return [String] the PayPal IPN attribute 'receiver_email' uniquely identifies the PayPal sandbox
    def paypal_id
      @ipn['receiver_email']
    end

    def ipn_valid?
      !@ipn_str.empty? && (@ipn_str =~ /(VERIFIED|INVALID)/) != 0
    end

  end
end
