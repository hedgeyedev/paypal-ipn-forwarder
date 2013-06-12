def configure(source_blob, destination_blob)
  cuke_cleaner   = CukeCleaner.new
  source_id      = cuke_cleaner.clean(source_blob)
  destination_id = cuke_cleaner.clean(destination_blob)
  organizer      = Organizer.new(source_id, destination_id)
  generator = TestIpnGenerator.new
  @ipn = generator.ipn
  @source         = organizer.source(@ipn)
  @destination    = organizer.destination
end

# When the server sends an ipn to my computer
When(/^(?:the|a|it) (.*?)sends (?:an|the) IPN(?: for the recurring payment|) to (?:my|the|an|a|)\s+(?:specified |recalcitrant |)(\w+)$/) do |source_blob, destination_blob|
  configure(source_blob, destination_blob)
end

Then(/^(the server|my computer) (?:notifies|alerts) (the developers|me) (.*?)$/) do |source, destinaton, problem|
  pending # express the regexp above with the code you wish you had
end

When(/^(?:the server|it) sends (?:an|the) IPN repeatedly for (\d+)(?: more|) days.+$/) do |days|
  pending # express the regexp above with the code you wish you had
end

Then(/^(?:the server|it) (?:notifies|has notified)\s+(.+?)(\d+) days$/) do |preamble, days|
  pending # express the regexp above with the code you wish you had
end

Given(/^the server (has|puts|purges) .+? IPN (?:in|into) the queue$/) do |action|
  pending # express the regexp above with the code you wish you had
end

Then(/.+?a successful response back to the (server|sandbox)$/) do |destination|
  @source.send_ipn.should == "a response"
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

Given(/^the server only contains an IPN for another computer$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the server purges the IPN$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^(?:the |)server (?:contains|has) (an|no) IPN.*?$/) do |content|
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

