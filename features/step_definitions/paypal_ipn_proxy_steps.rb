def configure(sandbox_id= nil, destination_id=nil)
  organizer      = Organizer.new(destination_id)
  generator = TestIpnGenerator.new
  @server         = organizer.server(@ipn)
  @destination    = organizer.destination
  @sandbox = organizer.sandbox
  @email = organizer.email
end

# When the server sends an ipn to my computer--deleted due to change of server-computer communication
# When a sandbox unknown to the server sends an IPN to the server
When(/^(?:the|a|) sandbox( unknown to the server|) sends an IPN( for the recurring payment|) to the server$/)do |state, paymenttype|
  unless(state == "")
    configure
    @ipn = @sandbox.send_fail
    @server.receive_ipn(@ipn)
  end
end

Then(/^the server notifies (?:.*?)(developer|developers) (.*?)$/) do |destinaton, problem|
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

Then(/it returns a successful response back to the sandbox$/) do
  pending #@source.send_ipn.should == "a response" -- will be deleted: outdated
end

When(/^the server receives an IPN from my assigned sandbox$/) do
  configure
  my_id = 'developer_one'
  @ipn = @sandbox.send
  @server.receive_ipn(@ipn)
  paypal_id  = @server.paypal_id
  my_id.should ==  @server.computer_id(paypal_id)
  @server.ipn.should == @sandbox.send
end

Then(/^the server hangs onto it until my assigned computer retrieves it$/) do
  @server.create_queue
  size_before = @server.queue_size
  @server.queue_push(@ipn)
  @server.queue_size.should == size_before+1


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

