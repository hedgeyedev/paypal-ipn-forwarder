class ServerClient

  def initialize(server)
    @server = server
  end

  def computer_testing(params)
    id = params['my_id']
    if params['test_mode'] == 'on'
      if (!@server.computer_online?(id))
        @server.begin_test_mode(id, params)
      elsif @server.same_sandbox_being_tested_twice?(id, params)
        @server.send_conflict_email(id, params['email'])
        @server.cancel_test_mode(id)
      end
    elsif (params['test_mode']== 'off')
      @server.cancel_test_mode(id)
    end
  end

  def respond_to_computer_poll(paypal_id, now=Time.now)
    @server.record_computer_poll(paypal_id)
    if(!@server.computer_online?(paypal_id))
      @server.unexpected_poll(paypal_id)
    elsif @server.ipn_response_present?(paypal_id)
      @server.send_verification
    else
      @server.send_ipn_if_present(paypal_id)
    end
  end

  def ipn_response(ipn)
    response = 'cmd=_notify-validate&' + ipn
    response
  end

  def receive_ipn(ipn=nil)
    @server.receive_ipn(ipn)
  end


end