require_relative 'poller'
class Router

  def initialize(target)
    @target = target
    @killing = false
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
    url = YAML::load_file(File.expand_path("../../config/router.yml", __FILE__))
  end

  def test_mode_on
    RestClient.post load_server_url, my_ip_address
  end

  def test_mode_off
    RestClient.post load_server_url, my_ip_address
  end

  #from: http://claudiofloreani.blogspot.com/2011/10/ruby-how-to-get-my-private-and-public.html
  def my_ip_address
    Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
  end

end
