Feature: Match PayPal sandboxes with developer computers
  As a developer
  I would like to have my own PayPal sandbox assigned to my local development computer only
  So I can use the sandbox confident that it is not receiving other developers' requests.
  TODO: Need glossary for 'computer', 'server'

  Scenario: Server receives an IPN from a sandbox assigned to my computer
    When the server receives an IPN from my assigned sandbox
    Then the server hangs onto it until my assigned computer retrieves it

  Scenario: My computer receives an IPN assigned to it from the server
    Given the server contains an IPN assigned to my computer
    When my computer polls the server for an IPN
    Then the server returns the IPN

  Scenario: My computer does NOT receive an IPN from a sandbox not assigned to me
    Given the server only contains an IPN for another computer
    When my computer polls the server for an IPN
    Then the server returns no IPN

  Scenario: Server has no developer computer assigned to receive IPNs from a PayPal sandbox
    When a sandbox unknown to the server sends an IPN to the server
    Then the server notifies the developers about the unknown PayPal sandbox

  Scenario: Computer has not polled server for a suspicious period of time.
    When the server has not been polled by a computer for 2 days
    Then the server notifies the developer that his computer hasn't responded for 2 days

  Scenario: Computer has not polled server for a considerable period of time.
    When the server has not been polled by a computer for 4 days
    Then the server notifies all of the developers that his computer hasn't responded for 4 days

  Scenario: Server has sandbox box entry but matching computer URL doesn't match any existing computer
    Given the server has notified a developer that his computer hasn't responded for 2 days
    When it sends the IPN repeatedly for 5 more days without response
    Then it notifies all of the developers that the zombie computer's owner has not responded for 5 days

  Scenario: PayPal sandbox repeatedly sends same IPN to unresponsive server

  Scenario: PayPal sandbox sends recurring payment IPN one year after test set up payment.

  Scenario: Developer concludes end-to-end testing episode
