class ServerPollChecker

  def initialize(test=nil)
    LoadConfig.set_test_mode(!test.nil?)
    @content = LoadConfig.new
  end

  def checkpoll(time)
    @time = time
    poll_times = @content.last_poll_time.clone
    poll_times.each_pair {|key, value|
    if(value >= Time.now - time)
      send_email(key)
      value = TIme.now
    end
    }

    sleep 60.0
  end

  def send_email(paypal_id)
    @email = {
        :to => @email_map[paypal_id],
        :from => 'email-proxy-problems@superbox.com',
        :subject => 'Your computer turned on test mode but has not polled in #{@time}. Please address this or these emails will continue',
        :body => 'on the Superbox IPN forwarder,your computer turned on test mode but has not polled in #{@time}. Please address this or these emails will continue'
    }

  end

end