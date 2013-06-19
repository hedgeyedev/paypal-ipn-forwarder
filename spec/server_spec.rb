require_relative 'spec_helper'
require_relative '../lib/server'
require_relative '../lib/sandbox'
require_relative '../lib/computer'

describe Server do

  it 'forwards an ipn from a paypal sandbox to its corresponding computer' do
    sb = Sandbox.new
    ipn = sb.send
    server = Server.new
    sandbox_id = server.receive_ipn(ipn)
    computer = Computer.new
    computer.receive_ipn(ipn)
    computer.ipn.should == ipn

  end


  it 'does not forward an ipn to a computer from a paypal sandbox that doesn\'t belong to it' do
      sb = Sandbox.new
      ipn = sb.send_fail
      server = Server.new
      sandbox_id = server.receive_ipn(ipn)
      comp_id = server.computer_id(sandbox_id)
      comp_id.should == nil
      computer = Computer.new
      computer.receive_ipn(ipn) unless comp_id == nil
      computer.ipn.should == nil
  end

  it 'sends an email to the developers when it receives an ipn from a sandbox that has no associated computer'

end