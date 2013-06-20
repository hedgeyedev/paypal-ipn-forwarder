require 'sinatra/base'
require 'rest_client'

# Run a demo to see if the port is opened up on the superbox

class Demo < Sinatra::Base

  def initialize(server = Server.new)
    @server = server
  end

  def launch_ipn
    cause_IPN_post_staement_against "localhost:8810/ipn/payemtns"
  end

  get '/invoke_ipn' do
    launch_ipn
  end

  post '/payments/ipn' do
    ipn = params[:splat].first
    response = @server.receive_ipn(ipn)
    url = “https://www.sandbox.paypal.com/cgi-bin/webscr” # this value needs to be verified

    RestClient.post url, ipn
  end

  # Pretend to be the PayPal sandbox you're sending the response back to
  post '/fake_payal' do

  end

  get '/' do
    # return a 404
  end

  run! if __FILE__ == $0

end

run Demo



