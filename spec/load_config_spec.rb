require 'rspec'
require_relative '../lib/load_config'

describe LoadConfig do

  TEST_MODE_ON = true

  before(:each) do
    LoadConfig.set_test_mode(TEST_MODE_ON)
    @config = LoadConfig.new
  end

  it 'retrieves the server URL' do
    @config.server_url.should == 'http://your_server.example.com'
  end


  it 'retrieves the developer computer URL for the router to send IPNs to' do
    @config.final_destination_url.should == 'http://localhost:3000/payments/ipn'
  end

  it 'retrieves the number of seconds between polls' do
    @config.polling_interval_seconds.should == '5.0'
  end

  it 'retrieves the email info which is constant' do
    @config.mail_creator.should == {:via=>:smtp, :via_options=>{:address=>'0.0.0.1', :openssl_verify_mode=>'none'}}
  end

  it 'retrieves the sandbox ids' do
    @config.sandbox_ids.should == ['my_sandbox_id', 'my_sandbox_id_1']
  end

  it 'retrieves the computer_testing booleans for the server hash' do
    @config.computer_testing.should == {'my_sandbox_id'=>false, 'my_sandbox_id_1'=>false}
  end

  it 'retrieves the queue map for the server' do
    @config.queue_map.should ==  {'my_sandbox_id'=>nil, 'my_sandbox_id_1'=>nil}
  end

  it 'retrieves a hash of the time that the last poll of an online computer occurred' do
    @config.last_poll_time.should == {'my_sandbox_id'=>nil, 'my_sandbox_id_1'=>nil}
  end

  it 'retrieves the map of ids to developer emails for sending email notificaitons' do
    @config.email_map.should == {'my_sandbox_id'=>'dmitri.ostapenko@gmail.com', 'my_sandbox_id_1'=>'bob@example.com'}
  end

  it 'retrieves a hash of when the last unexpected poll occured' do
    @config.poll_checker_instance.should == {'my_sandbox_id'=>nil, 'my_sandbox_id_1'=>nil}
  end

  it 'should retrieve the interval for poll checking in seconds' do
    @config.poll_checking_interval_seconds.should == '3600.0'
  end

end
