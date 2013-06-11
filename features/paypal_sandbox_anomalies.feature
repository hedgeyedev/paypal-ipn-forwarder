Feature: paypal sandbox anomalies
  As a developer
  I would like to know when there are PayPal sandbox anomalies
  So that such anomalies do not confuse me with other possibilities

  Scenario: Server not receiving IPNs from this sandbox
    Given the server is in test mode for this sandbox
    And an IPN generating test has started
    When the server has not received an IPN from the sandbox for ? minutes
    Then the server notifies me that it is not receiving any IPNs from my sandbox
