class WorkMailer < ApplicationMailer
default from: Rails.configuration.notification_email
 
  def deposit_work(from, body)
    mail(to: Rails.configuration.notification_email, from: from, subject: 'DBD: New Deposit', body: body)
  end

  def publish_work(from, body)
    mail(to: Rails.configuration.notification_email, from: from, subject: 'DBD: Work Published', body: body)
  end
end
