Then(/^it receives no response$/) do
  pending
end

Then(/^my computer does not receive it$/) do
  pending # express the regexp above with the code you wish you had
end

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

Then(/^the server notifies the developers about the unknown PayPal sandbox$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^(?:the server|it) sends (?:an|the) IPN repeatedly for (\d+)(?: more|) days.+$/) do |days|
  pending # express the regexp above with the code you wish you had
end

Then(/^(?:the server|it) (?:notifies|has notified)\s+(.+?)(\d+) days$/) do |preamble, days|
  pending # express the regexp above with the code you wish you had
end

Given(/^the server (has|puts|purges) .+? IPN (?:in|into|from) the queue$/) do |action|
  pending # express the regexp above with the code you wish you had
end

Then(/.+?a successful response back to the (server|sandbox)$/) do |destination|
  @source.send_ipn.should == "a response"
end

When(/^the server waits (\d+) seconds$/) do |seconds|
  pending # express the regexp above with the code you wish you had
end
