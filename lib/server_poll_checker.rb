class ServerPollChecker

  def initialize(test=nil)
    LoadConfig.set_test_mode(!test.nil?)
    @content = LoadConfig.new
  end

  def checkpoll(time, paypal_id)
    @time = time
    loop do
      poll_times = @content.last_poll_time.clone
      most_recent_poll_time = poll_times[paypal_id]
      if(most_recent_poll_time >= Time.now - time && !value.nil?)
        send_email(key)
        value = Time.now
      end
      }
      sleep 24.hours
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