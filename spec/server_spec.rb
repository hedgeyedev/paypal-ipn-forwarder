require_relative 'spec_helper'
require_relative '../lib/paypal-ipn-forwarder/server'
require_relative '../lib/paypal-ipn-forwarder/ipn'
require_relative '../lib/paypal-ipn-forwarder/router_client'

include PaypalIpnForwarder

describe Server do

  TEST_MODE_ON = true

  def add_linux_params_if_linux(mail_hash)
    unless HostInfo.new.running_on_osx?
      mail_hash.merge({ :via         => :smtp,
                        :via_options =>
                            {
                                :address             => 'localhost',
                                :openssl_verify_mode => 'none'
                            }
                      })
    else
      mail_hash
    end

  end

  context 'poll request' do

    before(:each) do
      @server     = Server.new
      @ipn        = Ipn.generate
      @sandbox_id = @ipn.paypal_id
    end

    it 'is responded to with an IPN when one is present' do
      @server.begin_test_mode(@sandbox_id, { 'sandbox_id' => @sandbox_id, 'test_mode' => 'on', 'email' => 'bob@example.com' })
      @server.receive_ipn(@ipn)
      @server.ipn_present?(@ipn.paypal_id).should == true
      @server.send_ipn_if_present(@ipn.paypal_id).should == @ipn
    end

    it 'does not forward an ipn to a computer from a paypal sandbox that does not belong to it' do
      id_1 = 'my_sandbox_id_1'
      id_2 = 'my_sandbox_id'
      @server.begin_test_mode(id_1, { 'sandbox_id' => id_1, 'test_mode' => 'on', 'email' => 'bob@example.com' })
      @server.begin_test_mode(id_2, { 'sandbox_id' => id_2, 'test_mode' => 'on', 'email' => 'bob@example.com' })
      @server.receive_ipn(@ipn)
      @server.ipn_present?(id_1).should == false
      @server.send_ipn_if_present(id_1).should == nil
    end

    it 'IPN denied from a router because no IPN exists for that router' do
      @server.begin_test_mode(@sandbox_id, { 'sandbox_id' => @sandbox_id, 'test_mode' => 'on', 'email' => 'bob@example.com' })
      @server.send_ipn_if_present(@sandbox_id).should == nil
    end

  end

  context 'queue' do

    before(:each) do
      @server     = Server.new(TEST_MODE_ON)
      @ipn        = Ipn.generate
      @sandbox_id = @ipn.paypal_id
      @server.begin_test_mode(@sandbox_id, { 'sandbox_id' => @sandbox_id, 'test_mode' => 'on', 'email' => 'bob@example.com' })
    end

    it 'stores IPNs sent from a sandbox when a computer is testing' do
      @server.receive_ipn(@ipn)
      @server.queue_size(@ipn.paypal_id).should == 1
      @ipn.should == @server.queue_pop(@sandbox_id)
    end

    it 'does NOT store IPNs sent from a sandbox when a computer is NOT testing' do
      @ipn.stub!(:paypal_id).and_return('fake paypal ID')
      @server.queue_size(@sandbox_id).should == 0
      @server.receive_ipn(@ipn)
      @server.queue_size(@sandbox_id).should == 0
    end

    it 'purges an IPN once it has been sent to the computer' do
      @server.receive_ipn(@ipn)
      paypal_id = @ipn.paypal_id
      @server.queue_size(paypal_id).should == 1
      @server.send_ipn_if_present(paypal_id)
      @server.queue_size(paypal_id).should == 0
    end

  end

  context 'receives polling request without test mode activated' do

    before(:each) do
      @server     = Server.new
      @ipn        = Ipn.generate
      @sandbox_id = @ipn.paypal_id
    end

    it 'should should send email to the developer on file for the failing sandbox' do
      paypal_id = @ipn.paypal_id

      # register test user and then cancel him so he has a entry:
      @server.begin_test_mode(@sandbox_id, { 'sandbox_id' => paypal_id, 'test_mode' => 'on', 'email' => 'bob@example.com' })
      @server.cancel_test_mode('bob@example.com')

      mail_hash = { :to      => 'bob@example.com',
                    :from    => PaypalIpnForwarder::EMAIL,
                    :subject => MailSender.build_subject_line(paypal_id),
                    :body    => MailSender::POLL_BEFORE_TEST_MODE_ON_ERROR + MailSender::HAPPENING_ONLY_TO_YOU,
      }
      mail_hash = add_linux_params_if_linux(mail_hash)
      Pony.should_receive(:mail).with(mail_hash)

      @server.record_computer_poll(@sandbox_id)
      @server.unexpected_poll(@sandbox_id)
    end

    it 'should sends email to all developers if no developer can be identified' do
      Pony.should_receive(:mail).with(any_args)
      @server.record_computer_poll('my_sandbox_unknown')
      @server.unexpected_poll('my_sandbox_unknown')
    end

    it 'should send another notification email if last email sent 24 ago as issue still not resolved' do

      def days(days_count)
        days_count * 24 * 60 * 60
      end

      UNKNOWN_SANDBOX = 'my_sandbox_unknown'
      Pony.should_receive(:mail).with(any_args).twice
      Timecop.freeze(Time.now - days(90)) do
        @server.record_computer_poll(UNKNOWN_SANDBOX)
        Timecop.freeze(Time.now + days(32)) do
          @server.unexpected_poll(UNKNOWN_SANDBOX)
          Timecop.freeze(Time.now + days(32)) do
            @server.unexpected_poll(UNKNOWN_SANDBOX)
          end
        end
      end
    end
  end

  context 'receives polling request with missing information' do

    before(:each) do
      @server     = Server.new
      @ipn        = Ipn.generate
      @sandbox_id = @ipn.paypal_id
    end

    it 'should send an email to the developer informing them of the problem' do
      Pony.should_receive(:mail).with(any_args)
      @server.poll_with_incomplete_info('email@email', 'off', '')
    end
  end

  context 'receives start test mode' do

    before(:each) do
      @server     = Server.new
      @ipn        = Ipn.generate
      @sandbox_id = @ipn.paypal_id
    end

    # not sure if test is too basic but added just in case
    it 'begins testings' do
      @server.begin_test_mode(@sandbox_id, { 'sandbox_id' => @sandbox_id, 'test_mode' => 'on', 'email' => 'bob@example.com' })
      @server.computer_online?(@sandbox_id).should == true
    end

  end

  context 'queue is not in test mode and something is trying to access it' do

    before(:each) do
      @server     = Server.new
      @ipn        = Ipn.generate
      @sandbox_id = @ipn.paypal_id
    end

    it 'sends an email to the developers' do

      mail_hash = { :to      => @server.developers_email,
                    :from    => MailSender::EMAIL,
                    :subject => Server::EMAIL_NO_QUEUE_SUBJECT,
                    :body    => @server.email_no_queue_body('my method', @sandbox_id)
      }
      mail_hash = add_linux_params_if_linux(mail_hash)
      Pony.should_receive(:mail).with(mail_hash)
      @server.queue_identify(@ipn.paypal_id, 'my method')

    end

  end

end
