require 'sinatra/base'
require 'rest_client'
# Run a demo to see if the port is opened up on the superbox


class Demo < Sinatra::Base

  get '/' do
    'Hello, world!'
  end

  post 'payments/ipn' do
    puts "got the post request"
    ipn = request.body.read
    unless ipn == 'VERIFIED' || ipn == 'INVALID'
      url = 'https://www.sandbox.paypal.com/cgi-bin/webscr'
      ipn = "cmd=_notify-validate&" + ipn
      RestClient.post url, ipn
    end
  end

  get '/launch' do
    url = 'http://localhost:7810/server/recieve'
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
    RestClient.post url, sample_ipn
  end

  post '/server/recieve' do
    url = 'http://localhost:6810/back/to/paypal'
    ipn = request.body.read
    ipn = "_notify-validate&" + ipn
    RestClient.post url, ipn
  end

  post '/back/to/paypal' do
    ipn = request.body.read
    url = 'http://superbox.hedgeye.com:8810/payments/ipn'
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

run Demo



