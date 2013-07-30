require 'sinatra/base'
require 'rest_client'
require 'cgi'
require File.expand_path('../lib/server_client', __FILE__)
require File.expand_path('../lib/server', __FILE__)
require File.expand_path('../lib/poller', __FILE__)
require File.expand_path('../lib/ipn_generator', __FILE__)
require File.expand_path('../lib/router_client', __FILE__)

# Run a demo to see if the port is opened up on the superbox

class ServerRack < Sinatra::Base
  configure do
    TEST_MODE_ON = true
    @@server = Server.new(TEST_MODE_ON)
    @@server_client = ServerClient.new(@@server)
    @@router = RouterClient.new(TEST_MODE_ON)
  #  set :server, Server.new
  ##  set :server_client, ServerClient.new(settings.server)
  end

  #methods still not working. TODO: fix them
  def self.initialize(server = ServerClient.new)
    @server = Server.new
    @server_client = ServerClient.new(@@server)
  end


  def self.launch_ipn
    cause_IPN_post_staement_against "localhost:8810/payemtns/ipn"
  end

  def self.cause_IPN_post_staement_against(url)
      sample_ipn = <<EOF
mc_gross=19.95&protection_eligibility=Eligible&address_status=confirmed&pay\
er_id=LPLWNMTBWMFAY&tax=0.00&address_street=1+Main+St&payment_date=20%3A12%\
3A59+Jan+13%2C+2009+PST&payment_status=Completed&charset=windows-\
1252&address_zip=95131&first_name=Test&mc_fee=0.88&address_country_code=US&\
address_name=Test+User&notify_version=2.6&custom=&payer_status=verified&add\
ress_country=United+States&address_city=San+Jose&quantity=1&verify_sign=Atk\
OfCXbDm2hu0ZELryHFjY-Vb7PAUvS6nMXgysbElEn9v-\
1XcmSoGtf&payer_email=gpmac_1231902590_per%40paypal.com&txn_id=61E67681CH32\
38416&payment_type=instant&last_name=User&address_state=CA&receiver_email=email\
&payment_fee=0.88&receiver_id=S8XGHLYDW9T3S\
&txn_type=express_checkout&item_name=&mc_currency=USD&item_number=&residenc\
e_country=US&test_ipn=1&handling_amount=0.00&transaction_subject=&payment_g\
ross=19.95&shipping=0.00
EOF
    RestClient.post url sample_ipn
  end


  get '/invoke_ipn' do

    ipn_send_test = IpnGenerator.new
    #puts "#{settings.server}"
    #$server = ServerClient.new(server)
    ipn_send_test.send_via_http "localhost:8810/payments/ipn"
   # RestClient.post "localhost:8810/payemtns/ipn", sample_ipn
  end

  get '/computer_poll' do
    #TODO: figure out what occurs if params nill
    # make sure request.body.read works
    params = request['sandbox_id']
    puts request['sandbox_id']
    puts @@server.computer_online?(params)
    @@server_client.respond_to_computer_poll(params)
  end

  post '/payments/ipn' do
    ipn = request.body.read
    #puts "#{settings.server}"
    #TODO: seperate paypal response and storing to get rid of bugs
    unless ipn == 'VERIFIED' || ipn == 'INVALID'
      @@server_client.receive_ipn(ipn)
      response = @@server_client.ipn_response(ipn)
      #url      = 'https://www.sandbox.paypal.com/cgi-bin/webscr'
      url = 'localhost:6810/receive_ipn/'
      RestClient.post url, response
    end
  end

  post '/test' do
    params = request.body.read
    @@server_client.computer_testing(params)
  end

  # Pretend to be the PayPal sandbox you're sending the response back to
  post '/fake_payal' do
  end

  get '/' do
    "Hello Wofrld"
  end

  get '/test_on' do
    @@router.set_test_mode('on', 'bib@example.com', 'my_sandbox_id')
  end

  get '/start_computer_poll' do
    poller = Poller.new(nil, 'http://localhost:8810/', 'my_sandbox_id')
    poller.retrieve_ipn
    #Restlient.get "localhost:8810/payments/ipn"
  end

  post '/receive_ipn/' do
  end

  post '/server/receive' do
    url = 'http://localhost:6810/back/to/paypal'
    ipn = request.body.read
    ipn = "_notify-validate&" + ipn
    RestClient.post url, ipn
  end

  post '/back/to/paypal' do
    ipn        = request.body.read
    url        = 'http://superbox.hedgeye.com:8810/payments/ipn'
    #url = 'http://localhost:5810/message'
    sample_ipn = <<EOF
mc_gross=19.95&protection_eligibility=Eligible&address_status=confirmed&pay\
er_id=LPLWNMTBWMFAY&tax=0.00&address_street=1+Main+St&payment_date=20%3A12%\
3A59+Jan+13%2C+2009+PST&payment_status=Completed&charset=windows-\
1252&address_zip=95131&first_name=Test&mc_fee=0.88&address_country_code=US&\
address_name=Test+User&notify_version=2.6&custom=&payer_status=verified&add\
ress_country=United+States&address_city=San+Jose&quantity=1&verify_sign=Atk\
OfCXbDm2hu0ZELryHFjY-Vb7PAUvS6nMXgysbElEn9v-\
1XcmSoGtf&payer_email=gpmac_1231902590_per%40paypal.com&txn_id=61E67681CH32\
38416&payment_type=instant&last_name=User&address_state=CA&receiver_email=email\
&payment_fee=0.88&receiver_id=S8XGHLYDW9T3S\
&txn_type=express_checkout&item_name=&mc_currency=USD&item_number=&residenc\
e_country=US&test_ipn=1&handling_amount=0.00&transaction_subject=&payment_g\
ross=19.95&shipping=0.00
EOF

    if ipn == "cmd=_notify-validate&"+sample_ipn
      message = 'VERIFIED'
    else
      message = 'INVALID'
    end

    RestClient.post url, message
  end

  post '/message' do
    ipn = request.body.read
  end

  run! if __FILE__ == $0


end

run ServerRack.new



