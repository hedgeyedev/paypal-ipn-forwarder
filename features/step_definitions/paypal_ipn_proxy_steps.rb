Then(/^my computer receives it$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^it acknowledges\s+(that |)it received it$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^my computer does not receive it$/) do
  pending # express the regexp above with the code you wish you had
end

def configure(source_blob, destination_blob)
  cuke_cleaner   = CukeCleaner.new
  source_id      = cuke_cleaner.clean(source_blob)
  destination_id = cuke_cleaner.clean(destination_blob)
  organizer      = Organizer.new(source_id, destination_id)
  source         = organizer.source
  destination    = organizer.destination
  return source, destination
end

# When the server sends an ipn to my computer
When(/^(the|a|it) (.*?)sends (an|the) IPN( for the recurring payment|) to (my|the|an|a|)\s+(specified |recalcitrant |)(\w+)$/) do |dummy, source_blob, dummy5, payment, dummy2, dummy3, destination_blob|
  source, destination = configure(source_blob, destination_blob)
  source.configure_ipn
  destination.should_receive(:request).with(ipn).and_return(response)
  source.send
end

Then(/^the server notifies the developers about the unknown PayPal sandbox$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^(the server|it) sends (an|the) IPN repeatedly for (\d+)( more|) days.+$/) do |dummy, dummy2, dummy3, days|
  pending # express the regexp above with the code you wish you had
end

Then(/^(the server|it) (notifies|has notified)\s+(.+?)(\d+) days$/) do |dummy, dummy2, preamble,days|
  pending # express the regexp above with the code you wish you had
end

Then(/^the server puts the IPN into a queue$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^it sends a successful response back to the sandbox$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^the server has an IPN in the queue$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the development computer sends a successful response back to the server$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the server purges the IPN from the queue$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^it gets no response$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^the server waits (\d+) seconds$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^the computer sends a successful response back$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the server purges the IPN from the queue\.$/) do
  pending # express the regexp above with the code you wish you had
end
