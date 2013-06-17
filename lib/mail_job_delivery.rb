# Custom delivery method for `ActionMailer`
#
# References
# ----------
#
# * [Rails Guides: ActionMailer](http://guides.rubyonrails.org/action_mailer_basics.html)
# * [`delivery_method`](http://api.rubyonrails.org/classes/ActionMailer/Base.html)
# * [`Mail::FileDelivery`](https://github.com/mikel/mail/blob/master/lib/mail/network/delivery_methods/file_delivery.rb) (and other classes in that directory)
class MailJobDelivery
  def initialize(*args)
  end

  def deliver!(mail)
    Job.enqueue!('Hedgeye::MailJob', :from_sucker_punch, paramify(mail))
  end

  private

  def paramify(mail)
    {
      # Has to be `to_a`, not `to_ary`, `Array()`, or `to_yaml` because of `Mail` internals (otherwise, it will be a `Mail::AddressContainer`)
      from: mail.from.to_a,
      to: mail.to.to_a,
      # this is the "SendGrid JSON SMTP API" we currently use to send categories
      x_smtpapi: mail.header["X-SMTPAPI"].value, # json in string form

      subject: mail.subject,
      # Without removing breaklines, the body is rendered with backslashes.
      # Possibly due to double encoding, i.e. \n -encode-> \\\n -decode-> \
      # TODO Create a cleaner solution in case we start depending on whitespace (such as using <pre>)
      body: mail.body.to_s.gsub(/\s+/,' ').strip
    }
  end
end
