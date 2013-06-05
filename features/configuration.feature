Feature: Match PayPal sandboxes with developer computers
  As a developer
  I would like to have my own PayPal sandbox assigned to my local development computer only
  So I can use the sandbox confident that it is not receiving other developers' requests.

  Scenario: My computer receives an IPN from my assigned sandbox
    When the server sends an IPN to my computer
    Then my computer receives it
    And it sends a successful response back to the server

  Scenario: My computer does NOT receive an IPN from a sandbox not assigned to me
    When a sandbox not assigned to me sends an IPN to the server
    Then my computer does not receive it

  Scenario: Server has no developer computer assigned to receive IPNs from a PayPal sandbox
    When a sandbox unknown to the server sends an IPN to the server
    Then the server notifies the developers about the unknown PayPal sandbox

  Scenario: Server has sandbox box entry matching computer doesn't response for too long a time
    When the server sends an IPN repeatedly for 2 days to a computer that doesn't respond
    Then the server notifies the developer that his computer hasn't responded for 2 days

  Scenario: Server has sandbox box entry but matching computer URL doesn't match any existing computer
    Given the server has notified a developer that his computer hasn't responded for 2 days
    When it sends the IPN repeatedly for 5 more days without response
    Then it notifies all of the developers that the zombie computer's owner has not responded for 5 days
