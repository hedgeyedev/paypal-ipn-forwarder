#my computer is in test mode
Given(/^(?:the|my) (computer|server) (is|is not) in (?:PayPal IPN |)test.*?mode.*?$/) do |subject, mode|
  server = Server.new
  dev_id = 'developer_one'
  server.dev_online(dev_id)
  server.computer_online_query(dev_id).should == true
end

Given(/^a test (has|has not) started$/) do |started|
  pending # express the regexp above with the code you wish you had
end

When(/^(?:the server|the computer) has not.*? polled .*?(\d+) (hour|days)$/) do |time, time_unit|
  pending # express the regexp above with the code you wish you had
end

Then(/^the computer's developer is notified that his computer has not polled for (\d+) hour$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end


Then(/^it notifies me that, after (\d+) days of no polling, my test mode has been turned off$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

When(/^the server receives a poll request from my computer.*?$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^should notify me that my computer is polling when it shouldn't$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^it waits (\d+) hours before sending a repeat notification if needed$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given(/^an IPN generating test has started$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^the server has not received an IPN from the sandbox for \? minutes$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^the server is not launched$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I go into test mode$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^my computer.*?the server that I'm in test mode$/) do
  server = Server.new
  id = "developer_one"
  server.dev_online(id)
  server.computer_online_query('developer_one').should == true
end

#When my computer turns off test mode
Then(/^(the server|my computer) turns off (?:my computer's |)test mode$/) do |subject|
  server = Server.new
  id = "developer_one"
  server.dev_offline(id)
  server.computer_online_query('developer_one').should == false
end

When(/^the server doesn't respond$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^the server knows that my computer is in test mode$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^an actual IPN generating test sequence has started on my computer$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^polling has not retrieved any IPNs for this test for (\d+) minutes$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end
