Feature: Handle PayPal IPN messages when my development environment is offline
  As a developer
  I would like for any IPN messages that the PayPal sandbox sends while my development machine is offline
    to be responded to by the server and queued for later handling by my development machine when it comes
    back online
  So that the development sandbox is not littered by unnecessary failed requests.

  Scenario: Queue an IPN request from the PayPal Sandbox

  Scenario: Determine whether the target development machine is online or not

  Scenario: Forward a queued IPN request to the development machine

  Scenario: Retain a queued IPN request in the queue when the development machine fails to process it
