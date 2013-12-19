require 'yaml'
require_relative 'host_info'
require_relative 'queue'
require_relative 'queue_map'

module PaypalIpnForwarder
  class LoadConfig

    SET_TEST_MODE = true

    def initialize(is_test_mode=false)
      dev_version = is_test_mode ? '_test' : ''
      @config     = YAML::load_file(File.expand_path("../../../config#{dev_version}.yml", __FILE__))
    end

    def server_url
      @config['server_url']
    end

    def development_computer_url
      @config['development_computer_url']
    end

    def polling_interval_seconds
      @config['polling_interval_seconds']
    end

    def sandbox_ids
      @config['sandbox_id']
    end

    def computer_testing
      @config['computer_testing']
    end

    def queue_map
      @config['queue_map']
    end

    def last_poll_time
      @config['last_poll_time']
    end

    def email_map
      @config['email_map']
    end

    def poll_checker_instance
      @config['poll_checker_instance']
    end

    def poll_checking_interval_seconds
      @config['poll_checking_interval_seconds']
    end

    def no_polling_time_before_email
      @config['no_polling_time_before_email']
    end

    def no_ipn_time_before_notification
      @config['no_ipn_time_before_email']
    end

    def ipn_reception_checker_instance
      @config['ipn_reception_checker_instance']
    end

    def developers_email
      @config['developers_email']
    end

  end
end
