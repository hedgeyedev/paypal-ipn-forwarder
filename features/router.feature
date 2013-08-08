Feature:
  As a developer
  I would like to have a means of polling for PayPal IPN notifications from our server
  and forwarding those to our internal PayPal IPN client
  So that the server doesn't have to push those IPN notifications directly through firewalls to our PayPal IPN client.

  Scenario: Server not responding to my PayPal sandbox's IPN notifications
    Given the server knows that my computer is in test mode
    When an actual IPN generating test sequence has started on my computer
    And polling has not retrieved any IPNs for this test for 10 minutes
    Then my computer alerts me that it is not receiving any IPNs from the server




  Scenario: Server not accumulating IPNs
    TODO (maybe)

  Scenario: Server not disposing of IPNs after computer retrieves them
    TODO (maybe)
