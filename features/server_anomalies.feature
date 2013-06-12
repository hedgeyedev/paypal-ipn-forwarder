Feature: gracefully handle server anomalies
  As a developer
  I would like for the environment to behave appropriately when the server has issues
  So that the anomaly doesn't cause a mess

  Scenario: Server is not started
    Given the server is not launched
    And my computer is not in PayPal IPN testing mode
    When I go into test mode
    And my computer informs the server that I'm in test mode
    And the server doesn't respond
    Then my computer alerts me that the server didn't respond

  Scenario: Server not responding to my PayPal sandbox's IPN notifications
    Given the server knows that my computer is in test mode
    When an actual IPN generating test sequence has started on my computer
    And polling has not retrieved any IPNs for this test for 10 minutes
    Then my computer notifies me that it is not receiving any IPNs from the server

  Scenario: Server not responding to computer polling requests
    Given the server is in test mode
    And my computer is in PayPal IPN testing mode
    When my computer polls the server
    And the server doesn't respond
    Then my computer notifies me that the server is not responding to polling

  Scenario: Server not accumulating IPNs
    TODO (maybe)

  Scenario: Server not disposing of IPNs after computer retrieves them
    TODO (maybe)
