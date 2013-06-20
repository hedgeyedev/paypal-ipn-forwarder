Feature:
  As a developer
  I would like to have a means of polling for PayPal IPN notifications from our server
  and forwarding those to our internal PayPal IPN client
  So that the server doesn't have to push those IPN notifications directly through firewalls to our PayPal IPN client.

  Scenario: Server not responding to my PayPal sandbox's IPN notifications
    Given the server knows that my computer is in test mode
    When an actual IPN generating test sequence has started on my computer
    And polling has not retrieved any IPNs for this test for 10 minutes
    Then my computer notifies me that it is not receiving any IPNs from the server

  Scenario: Server is not started
    Given the server is not launched
    And my computer is not in PayPal IPN testing mode
    When I go into test mode
    And my computer informs the server that I'm in test mode
    And the server doesn't respond
    Then my computer alerts me that the server didn't respond

  Scenario: Server not responding to computer polling requests
    Given my computer is in PayPal IPN testing mode
    When my computer polls the server
    And the server doesn't respond
    Then my computer notifies me that the server is not responding to polling
