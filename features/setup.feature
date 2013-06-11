Feature: Setup
  As a developer
  I only want to bother with this environment when i am specifically testing PayPal IPNs
  So that I don't have any testing activity taxing my computer's resources when I'm not doing this

  Scenario: turn on PayPal IPN testing
    When my computer notifies the server that it wants to process IPNs
    Then henceforth the server accumulates any IPNs for my computer sent to it

  Scenario: turn off PayPal IPN testing
    When my computer notifies the server that it is offline
    Then henceforth any IPNs received from my computer's PayPal sandbox are simply acknowledged successfully
    And the IPNs are not accumulated

