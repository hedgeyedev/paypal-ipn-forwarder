def configure
  organizer      = Organizer.new
  generator = TestIpnGenerator.new
  @server         = organizer.server
  @computer    = organizer.computer
  @sandbox = organizer.sandbox
  @email = organizer.mail_sender
end

# When a sandbox unknown to the server sends an IPN to the server
# When the sandbox sends an IPN for the recurring payment to the server
When(/^(?:the|a|) sandbox( unknown to the server|) sends an IPN( for the recurring payment|) to the server$/)do |state, payment_type|
    configure
    dev_id = 'my_sandbox_id'
    @server.computer_testing({'my_id' => dev_id, 'test_mode' => 'on', 'email' => 'bob@example.com'})
    if(payment_type != "")
      @ipn = @sandbox.send_recurring
    elsif (state != '')
      @ipn = @sandbox.send_fail
    end
    #@server.receive_ipn(@ipn)
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

  #this method works for when a queue should be popping or pushing into a queue
  @server.no_computer_queue(problem)
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
    @server.ipn_response(@ipn)
end

When(/^the server receives an IPN from my assigned sandbox$/) do
  configure
  my_id = 'my_sandbox_id'
  @ipn = @sandbox.send
  @server.computer_testing({'my_id' => my_id, 'test_mode' => 'on', 'email' => 'bob@example.com'})
  @server.receive_ipn(@ipn)
  paypal_id  = @server.paypal_id(@ipn)
  my_id.should ==  paypal_id
  @server.queue_pop(my_id).should == @sandbox.send
end

Then(/^the server hangs onto it until my assigned computer retrieves it$/) do
  my_id = 'my_sandbox_id'
  @server.receive_ipn(@ipn)
  @server.computer_testing({'my_id' => my_id, 'test_mode' => 'on', 'email' => 'bob@example.com'})
  size_before = @server.queue_size(my_id)
  @server.queue_push(@ipn)
  @server.queue_size(my_id).should == size_before+1
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

