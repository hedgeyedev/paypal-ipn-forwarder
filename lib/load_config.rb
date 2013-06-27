require 'yaml'

class LoadConfig

  def initialize
    dev_version = @@test_mode ? '_test' : ''
    @config = YAML::load_file(File.expand_path("../../config#{dev_version}.yml", __FILE__))
  end

  def self.set_test_mode(mode_boolean)
    if(mode_boolean)
      @@test_mode = true
    else
      @@test_mode = false
    end
  end

  def server_url
    @config['server_url']
  end

  def development_computer_url
    @config['development_computer_url']
  end

  def mail_creator
    hash = Hash.new
    hash[:via] = @config[:via]
    hash[:via_options] = @config[:via_options]
    hash
  end

  def polling_interval_seconds
    @config['polling_interval_seconds']
  end

  def sandbox_ids
    @config['sandbox_id']
  end

  def sandbox_map
    @config['map']
  end

  def computer_testing
    @config['computer_testing']
  end

  def ipn_response
    @config['ipn_response']
  end

  def queue_map
    @config['queue_map']
  end

end
