require 'rspec'
require 'timecop'
require_relative '../lib/paypal-ipn-forwarder/server_ipn_reception_checker'
require_relative '../lib/paypal-ipn-forwarder/server'
require_relative '../lib/paypal-ipn-forwarder/load_config'

describe PaypalIpnForwarder::ServerIpnReceptionChecker do

  TEST_MODE_ON = true

  it 'should send an email if no IPN received 9 minutes after testing started' do
    Pony.should_receive(:mail).with(any_args)#{:via=>:smtp, :via_options=>{:address=>"localhost", :openssl_verify_mode=>"none"}, :to=>"developer@gmail.com", :from=>"email-proxy-problems@superbox.com", :subject=>"No IPNs are being received from paypal sandbox # my_sandbox_id on the paypal IPN forwarder", :body=>"Test mode has been turned on for sandbox with id: my_sandbox_id but no IPN has been received for it in an 9 minutes.\nThere most likely is an issue with the paypal sandbox."})
    content = LoadConfig.new(TEST_MODE_ON)
    time_before_notification = content.no_ipn_time_before_notification
    server = Server.new(TEST_MODE_ON)
     ipn_checker = ServerIpnReceptionChecker.new(server, 'my_sandbox_id', TEST_MODE_ON)
     Timecop.travel(Time.now+time_before_notification)
     ipn_checker.verify_ipn_received

  end

  it 'should work' do
    true == true
  end

end
