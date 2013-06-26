def configure
  organizer      = Organizer.new
  generator = TestIpnGenerator.new
  @server_client         = organizer.server_client
  @computer    = organizer.computer
  @sandbox = organizer.sandbox
  @email = organizer.mail_sender
end

# When the server sends an ipn to my computer--deleted due to change of server-computer communication
# When a sandbox unknown to the server sends an IPN to the server
# When the sandbox sends an IPN for the recurring payment to the server
When(/^(?:the|a|) sandbox( unknown to the server|) sends an IPN( for the recurring payment|) to the server$/)do |state, payment_type|
  unless(state == "")
    configure
    if(payment_type == "")
      @ipn = @sandbox.send_fail
    else
      @ipn = @sandbox.send_recurring
    end
    @server_client.receive_ipn(@ipn)
  end
end

Then(/^the server notifies (?:.*?)(developer|developers|me) (.*?)$/) do |destinaton, problem|
  configure

  if(destinaton == "developers")
    to = "developers"
  else
    to = "developer"
  end

  cleaner = ProblemCleaner.new
  problem = cleaner.clean(problem)

  EMAIL = {
    :to => to,
    :from => "email-proxy-problems@superbox.com",
    :subject => problem,
    :body => "on the Superbox IPN forwarder, this error occured:\n" + problem + "\nplease address it.\nThank You"
  }

  @email.send(EMAIL)
end

Given(/^the server (has|puts|purges|contains|only contains) (no|the|an) IPN .*?(?:in|into|from|to|for|available for) (my computer|another computer|the server)$/) do |action, existance ,assignment_blob|
  pending # express the regexp above with the code you wish you had
end

Given(/^the server (has|puts|purges|contains|only contains) (no|the|an) IPN$/) do |action, existance|
  pending
end

Then(/the server returns a successful response back to the sandbox$/) do
    configure
    @ipn = @sandbox.send_recurring
    @server_client.ipn_response(@ipn)
end

When(/^the server receives an IPN from my assigned sandbox$/) do
  configure
  my_id = 'developer_one'
  @ipn = @sandbox.send
  @server_client.receive_ipn(@ipn)
  paypal_id  = @server_client.paypal_id(@ipn)
  my_id.should ==  @server_client.computer_id(paypal_id)
  @server_client.ipn.should == @sandbox.send
end

Then(/^the server hangs onto it until my assigned computer retrieves it$/) do
  @server_client.create_queue
  size_before = @server_client.queue_size
  @server_client.queue_push(@ipn)
  @server_client.queue_size.should == size_before+1
end

When(/^(:?.*?)computer( does not|) poll(:?.*?)the server (:?.*?)an IPN$/) do |action|
  pending # express the regexp above with the code you wish you had
end

Then(/^the IPN continues to be stored in the server$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^.*?poll.*?the server$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the server returns (no|the) IPN.*?$/) do |content|
  pending # express the regexp above with the code you wish you had
end

Then(/^henceforth the server accumulates any IPNs for my computer sent to it$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^henceforth any IPNs received from my computer's PayPal sandbox are simply acknowledged successfully$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the IPNs are not accumulated$/) do
  pending # express the regexp above with the code you wish you had
end

