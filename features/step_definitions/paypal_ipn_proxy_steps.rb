Then(/^.+? receives (it|no response)$/) do |responce|
  pending # express the regexp above with the code you wish you had
end

Then(/^my computer does not receive it$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^(the|a|it) (.*?)sends (an|the) IPN( for the recurring payment|) to (my|the|an|a|)\s+(specified |recalcitrant |)(\w+)$/) do |dummy, source, dummy5, payment, dummy2, dummy3, destination|
  pending # express the regexp above with the code you wish you had
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

Given(/^the server (has|puts|purges) .+? IPN (in|into|from) the queue$/) do |action, dummy|
  pending # express the regexp above with the code you wish you had
end

Then(/.+?sends a successful response back to the (server|sandbox)$/) do |destination|
  pending # express the regexp above with the code you wish you had
end

When(/^the server waits (\d+) seconds$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end
