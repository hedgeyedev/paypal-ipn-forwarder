def configure(source_blob, destination_blob)
  cuke_cleaner   = CukeCleaner.new
  source_id      = cuke_cleaner.clean(source_blob)
  destination_id = cuke_cleaner.clean(destination_blob)
  organizer      = Organizer.new(source_id, destination_id)
  generator = TestIpnGenerator.new
  @ipn = generator.ipn
  @source         = organizer.source(@ipn)
  @destination    = organizer.destination
  @is_incoming_msg = msg_incoming?
end

# From information about the configuration, determine whether
# the step definition is defining a message going into the server
# or a message that the server is sending out.
def msg_incoming?
  # don't know how to do this yet.
end

# Handle an IPN being processed by the server, either receiving from the PayPal sandbox or being sent to the computer
When(/^(?:the|a|it) (sandbox|server) sends (?:an|the) IPN(?: for the recurring payment|) to (?:my|the|an|a|)\s+(?:specified |recalcitrant |)(\w+)$/) do |source, destination_blob|
  configure(source, destination_blob)

  @ipn_response = @source.send_ipn
end

Then(/^(the server|my computer) (?:notifies|alerts) (the developers|the developer|me|all of the developers) (.*?)$/) do |source, destinaton, problem|
  pending # express the regexp above with the code you wish you had
end

Given(/^the server (has|puts|purges|contains|only contains) (no|the|an) IPN .*?(?:in|into|from|to|for|available for) (my computer|another computer|the server)$/) do |action, existance ,assignment_blob|
  pending # express the regexp above with the code you wish you had
end

Given(/^the server (has|puts|purges|contains|only contains) (no|the|an) IPN$/) do |action, existance|
  pending
end

Then(/(?:it|the server) a successful response back to the (server|sandbox)$/) do |destination|
  @ipn_response.should == "a response"
end

Then(/^the server returns a successful response back to the sandbox$/) do
  @ipn_response.success.should == 'successful' # PayPal-specific; get the right key and value
end

When(/^the server receives an IPN from my assigned sandbox$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the server hangs onto it until my assigned computer retrieves it$/) do
  pending # express the regexp above with the code you wish you had
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

