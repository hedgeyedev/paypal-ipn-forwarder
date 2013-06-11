Feature: developer computer anomalies
  As a developer
  I would like for this system to be well-behaved
  So that it doesn't mislead me or otherwise fall apart when mildly-unexpected computer events occur

  Scenario: computer stops polling after testing started
    Given that my computer is in PayPal IPN testing mode
    And a test has started
    When the computer has not polled after 1 hour
    Then the computer's developer is notified that his computer has not polled for 1 hour

  Scenario: computer stops polling while in PayPal IPN test mode
    Given that my computer is in PayPal IPN testing mode
    And a test has not started
    When the computer has not polled after 4 days
    Then the server turns off my computer's test mode
    And it notifies me that, after 4 days of no polling, my test mode has been turned off

  Scenario: computer starts polling while not in PayPal IPN test mode
    Given that my computer is not in PayPal IPN testing mode
    And it is polling the server
    When the server receives a poll request from my computer
    Then should notify me that my computer is polling when it shouldn't
    And it waits 24 hours before sending a repeat notification if needed
