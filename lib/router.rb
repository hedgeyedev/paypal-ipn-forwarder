require_relative 'poller'
class Router

  def initialize(target, server_client)
    @target = target
    @killing = false
    @server_client = server_client
  end


  def forward_ipn(ipn)
      if(ipn == "VERIFIED")
         send_verified
      else
        send_ipn(ipn)
      end
    end

  def send_verified#same functionality as send_verification
    @target.verified
  end

  def send_ipn(ipn)
   @target.send_ipn(ipn)
  end

  def load_server_url
    url = YAML::load_file(File.expand_path("../../config/config.yml", __FILE__))
  end

  def test_mode_on
    RestClient.post load_server_url, my_ip_address
  end

  def test_mode_off
    url = 'http://superbox.hedgeye.com:8810/test/'
    message = ip_address
    @server_client.post @url, message
  end

  def my_ip_address #from: http://claudiofloreani.blogspot.com/2011/10/ruby-how-to-get-my-private-and-public.html
    Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
  end

end
