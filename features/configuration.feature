Feature: Match PayPal sandboxes with developer computers
  As a developer
  I would like to have my own PayPal sandbox assigned to my local development computer only
  So I can use the sandbox confident that it is not receiving other developers' requests.
  TODO: Need glossary for 'computer', 'server'

  Scenario: Server receives an IPN from a sandbox assigned to my computer
    When the server receives an IPN from my assigned sandbox
    And my computer is in test mode
    Then the server hangs onto it until my assigned computer retrieves it

  Scenario: My computer retrieves an IPN assigned to it from the server
    Given the server contains an IPN assigned to my computer
    When my computer polls the server for an IPN
    Then the server returns the IPN
    And the server purges the IPN

  Scenario: My computer does NOT retrieve an IPN from a sandbox not assigned to me
    Given the server only contains an IPN for another computer 
    When my computer polls the server for an IPN
    Then the server returns no IPN

  Scenario: Server has no developer computer assigned to retrieve IPNs
    When a sandbox unknown to the server sends an IPN to the server
    Then the server notifies the developers about the unknown PayPal sandbox

  Scenario: Computer has not polled server for a suspicious period of time.
    When the server has not been polled by a computer for 2 days
    Then the server notifies the developer that his computer hasn't responded for 2 days

  Scenario: Computer has not polled server for a considerable period of time.
    When the server has not been polled by a computer for 4 days
    Then the server notifies all of the developers that his computer hasn't responded for 4 days

  Scenario: PayPal sandbox repeatedly sends same IPN to unresponsive server

  Scenario: PayPal sandbox sends recurring payment IPN one year after test set up payment.

  Scenario: Developer concludes end-to-end testing episode
