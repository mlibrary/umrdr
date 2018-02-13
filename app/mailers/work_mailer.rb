include EmailHelper

class WorkMailer < ApplicationMailer
  default from: EmailHelper.notification_email

  layout "mailer.html"
 
  def create_work( to: EmailHelper.notification_email, from: '', body: '' )
    mail( to: to, from: from, subject: 'DBD: New Work Created', body: body )
  end

  def deposit_work( to: EmailHelper.notification_email, from: '', body: '' )
    mail( to: to, from: from, subject: 'DBD: New Deposit', body: body )
  end

  def delete_work( to: EmailHelper.notification_email, from: '', body: '' )
    mail( to: to, from: from, subject: 'DBD: Work Deleted', body: body )
  end

  def globus_job_complete( to, body )
    mail( to: to, from: to, subject: 'DBD: Globus Work Files Available', body: body )
  end

  def globus_job_started( to: EmailHelper.notification_email, from: '', body: '' )
    mail( to: to, from: to, subject: 'DBD: Globus Work Copy Job Started', body: body )
  end

  def globus_push_work( to, from, body )
    mail( to: to, from: from, subject: 'DBD: Globus Work Files Prepared', body: body )
  end

  def publish_work( to: EmailHelper.notification_email, from: '', body: '' )
    mail( to: to, from: from, subject: 'DBD: Work Published', body: body )
  end

  def update_work( to: EmailHelper.notification_email, from: '', body: '' )
    mail( to: to, from: from, subject: 'DBD: Work Updated', body: body )
  end

end
