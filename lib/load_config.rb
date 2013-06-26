require 'yaml'

class LoadConfig

  def initialize(dev_version=nil)
    @config = YAML::load_file(File.expand_path("../../config#{dev_version}.yml", __FILE__))
  end

  def server_url
    @config['server_url']
  end

  def development_computer_url
    @config['development_computer_url']
  end

end
