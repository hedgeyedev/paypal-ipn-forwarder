require 'rspec'
require 'timecop'
require_relative '../lib/server_ipn_reception_checker'
require_relative '../lib/server'

describe ServerIpnReceptionChecker do

  TEST_MODE_ON = true

  it 'should send an email if no IPN received 9 minutes after testing started' do
    Pony.should_receive(:mail).with(any_args)#{:via=>:smtp, :via_options=>{:address=>"localhost", :openssl_verify_mode=>"none"}, :to=>"dmitri.ostapenko@gmail.com", :from=>"email-proxy-problems@superbox.com", :subject=>"No IPNs are being received from paypal sandbox # my_sandbox_id on the paypal IPN forwarder", :body=>"Test mode has been turned on for sandbox with id: my_sandbox_id but no IPN has been received for it in an 9 minutes.\nThere most likely is an issue with the paypal sandbox."})
     server = Server.new(TEST_MODE_ON)
     ipn_checker = ServerIpnReceptionChecker.new(server, 'my_sandbox_id', TEST_MODE_ON)
     Timecop.travel(Time.now+60*9)
    ipn_checker.verify_ipn_received

  end

  it 'should work' do
    true == true
  end

end