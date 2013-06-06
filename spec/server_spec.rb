require_relative 'spec_helper'

describe Server do
  
  it 'forwards an ipn from a paypal sandbox to its corresponding computer'
  
  it 'does not forward an ipn to a computer from a paypal sandbox that doesn\'t belong to it'
   
  it 'sends an email to the developers when it receives an ipn from a sandbox that has no associated computer'

end