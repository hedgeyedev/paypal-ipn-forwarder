require 'sinatra/base'

# Run a demo to see if the port is opened up on the superbox

class Demo < Sinatra::Base

  get '/' do
    'Hello, world!'
  end

  run! if __FILE__ == $0

end

run Demo



