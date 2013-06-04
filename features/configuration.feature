Feature: Match PayPal sandboxes with developer computers
  As a developer
  I would like to have my own PayPal sandbox assigned my my local development only
  So that I can use the sandbox confident that it is not receiving other developers' requests.

  Scenario: My computer receives an IPN from my assigned sandbox
    Given that the server has an IPN to deliver to my computer
    When the server sends the IPN to my computer
    Then my computer receives it
    And it acknowledges that it received it.

  Scenario: My computer does NOT receive an IPN from a sandbox not assigned to me
    Given that a sandbox not assigned to me has an IPN notification to send
    When it sends the IPN to the server
    Then my computer does not receive it

  Scenario: Server has no developer computer assigned to receive IPNs from a PayPal sandbox
    Given that a PayPal sandbox has an IPN to send
    And the server configuration has no entry for the PapPal sandbox ID
    When the sandbox sends the IPN
    Then the server notifies the developers about the rogue PayPal sandbox.

  Scenario: Server has sandbox box entry matching computer doesn't response for too long a time
    Given that the server has an IPN to send to a computer that doesn't exist
    When it sends the IPN repeatedly for x days without response
    Then it notifies the developer for the zombie computer that it hasn't found it online for x days

  Scenario: Server has sandbox box entry but matching computer URL doesn't match any existing computer
    Given that the server has an IPN to send to a computer that doesn't exist
    When it sends the IPN repeatedly for x days without response
    Then it notifies the developer for the zombie computer that it hasn't found it online for x days
    When it sends the IPN repeatedly for y more days without response
    Then it notifies all of the developers that the zombie computer's owner has not responded for y days
