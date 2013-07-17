Feature: Match PayPal sandboxes with developer computers
  As a developer
  I would like to have my own PayPal sandbox assigned to my local development computer only
  So I can use the sandbox confident that it is not receiving other developers' requests.
  #TODO: Need glossary for 'computer', 'server'

  Scenario: Server has no developer computer assigned to retrieve IPNs
    When a sandbox unknown to the server sends an IPN to the server
    Then the server notifies the developers about the unknown PayPal sandbox
    #above scenario should be deleted, no longer being implemented this way

    #all computer not polling when test mode on scenarios covered in server_poll_checker_spec

  Scenario: PayPal sandbox repeatedly sends same IPN to unresponsive server

  Scenario: PayPal sandbox sends recurring payment IPN one year after test set up payment.

  Scenario: Developer concludes end-to-end testing episode
