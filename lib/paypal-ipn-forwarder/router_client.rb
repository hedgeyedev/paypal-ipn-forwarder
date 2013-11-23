require_relative 'load_config'

module PaypalIpnForwarder
  class RouterClient

    def initialize(set_test_mode=false)
      @config = LoadConfig.new(set_test_mode)
      @server_url = @config.server_url
      @server_url += 'test'
      @development_computer_url = @config.development_computer_url
    end

    def send_ipn(ipn)
      puts 'An IPN was received! I am now trying to send it to the final destination.'
      begin
        RestClient.post @development_computer_url, ipn
      rescue StandardError
        puts 'There was an error with the App where the IPN needs to be delivered. Please make sure it is running'
      end
    end

    def set_test_mode(mode, email, sandbox_id)
      RestClient.post(@server_url, {'sandbox_id' => sandbox_id, 'test_mode' => mode, 'email' => email
      })
    end

  end
end
