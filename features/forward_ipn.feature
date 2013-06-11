Feature: forward an IPN from PayPal to a development machine
  As a developer
  I would like for my development setup to respond to IPN messages from my PayPal sandbox
  So I can more fully simulate the PayPal production environment in my development space.

  Scenario: PayPal sandbox sends IPN to common server
    When the sandbox sends an IPN for the recurring payment to the server
    Then the server puts the IPN into the queue
    And it returns a successful response back to the sandbox

  Scenario: Developer computer retrieves IPN from server
    Given the server has an IPN available to the computer
    When the computer polls the server to retrieve an IPN
    Then the server returns the IPN back to the computer as part of the computer's request
    And the server purges the IPN

  Scenario: Developer computer is offline
    Given the server has an IPN available for my computer
    When my computer does not poll the server for an IPN
    Then the IPN continues to be stored in the server

  Scenario: Developer computer polls and server has no IPN for it
    Given the server has no IPN available for my computer
    When my computer polls the server
    Then the server returns no IPN available

# The developer computer doesn't have a notion of being online or not
#  Scenario: Developer computer is online but doesn't send a response

  # Do we want to be able to simulate a failed response from our production server?
  # At this point, let's treat this as low priority.  Cost: Will have to rethink
  # the server sending back early responses to PayPal.  Dmitri has the idea
  # that this scenario doesn't run from the development computer but from
  # the server (i.e. a special test mode), because in this specific scenario
  # we're testing paypal and not our software
#  Scenario: Developer computer is online but sends a fail response

  # Since PayPal gets successful responses always, it will not retry (at least very often),
  # so this is unlikely to become a storage problem for a long time.  Postpone to later if ever
#  Scenario: Purge undelivered IPNs from the queue

#  Scenario: Developer computer is offline and the server waits to resent until the computer sends back a notification
#  it is back online
#    Given the server has an IPN to send to the developer computer
#    When it sends the IPN to the specified computer
#    Then it gets no response
#    And the server waits indefinitely to get an online notification from the computer
#    When the computer comes online
#    And it sends a notification to the server that it is back online
#    Then the server resends the IPN to the computer
#    When the computer receives the IPN successfully
#    Then it will send back a successful response
#    When the server receives the response from the computer
#    Then it purges the IPN from the queue
