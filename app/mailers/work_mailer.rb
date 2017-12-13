include EmailHelper

class WorkMailer < ApplicationMailer
  default from: EmailHelper.notification_email

  layout "mailer.html"
 
  def deposit_work(from, body)
    mail( to: EmailHelper.notification_email, from: from, subject: 'DBD: New Deposit', body: body )
  end

  def globus_job_complete( to, body )
    mail( to: to, from: to, subject: 'DBD: Globus Work Files Available', body: body )
  end
  
  def publish_work(from, body)
    mail( to: EmailHelper.notification_email, from: from, subject: 'DBD: Work Published', body: body )
  end
    
  def globus_push_work( to, from, body )
    mail( to: to, from: from, subject: 'DBD: Globus Work Files Prepared', body: body )
  end

end
