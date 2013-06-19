describe queue do
  it 'stores IPNs sent from a sandbox when a computer is testing' do
    server = Server.new
    sb = Sandbox.new
    dev_id = 'developer_one'
    server.dev_online(dev_id)
    #TODO: finish
  end

  it 'pops IPNs when SendGrid asks for them'

  it 'doesnt store IPNs sent from a sandbox when a computer is not testing'
  #not sure if this is needed but added just in case. Discuss with Scott
end