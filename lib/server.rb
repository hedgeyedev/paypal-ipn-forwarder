class Server

  def initialize(ipn=nil)
    @ipn = ipn unless ipn.nil?
  end

  def send_ipn
    computer = Computer.new
    computer.send_ipn @ipn
  end

end
