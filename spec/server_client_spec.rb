require 'rspec'
require_relative '../lib/server_client'

describe ServerClient do

  it 'should receive a testing ON HTTP request from the router and turn ON testing for the sandbox'

  it 'should receive a testing OFF HTTP request from the router and turn OFF testing for the sandbox'

  it 'should receive a poll from a development computer and respond to it'

  it 'should receive IPNs and forward them to the server'

  it 'should create the response to a sandbox when it has sent an IPN'

  it 'should not respond to VERIFIED messages send from the sandbox'

end