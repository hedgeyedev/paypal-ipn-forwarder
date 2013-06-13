require 'sinatra/base'
require 'rest_client'
# Run a demo to see if the port is opened up on the superbox

class Demo < Sinatra::Base

  get '/' do
    'Hello, world!'
  end

  get '/launch' do
    url = 'localhost:8810/'
    ipn = "bobslef"
    RestClient.get url
  end

  post '/payments/ipn' do
      #@ipn = params[:splat].first
        @ipn = request.body.string
       url = "https://www.sandbox.paypal.com/cgi-bin/webscr"
       #@ipn = " _notify-validate&"+@ipn
       RestClient.post url, @ipn

     end

  run! if __FILE__ == $0


end

run Demo



