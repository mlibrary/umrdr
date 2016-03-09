class WorkMailer < ApplicationMailer
default from: Sufia.config.notification_email
 
  def deposit_work(from, body)
    mail(to: Sufia.config.notification_email, from: from, subject: 'DBD: New Deposit', body: body)
  end
end
