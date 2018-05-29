class Notifier < ApplicationMailer

  def self.report_load_event(event)
    admin_addresses.each { |email_addr|
      send_msg(email_addr, event.subject_line, event.email_message).deliver_now
    }
  end

  def self.report_user_event(event_type, user)
    admin_addresses.each { |email_addr| send_user_event_msg(email_addr, user, event_type).deliver_now }
  end

  def send_user_event_msg(email_addr, user, event_type)
    send_msg(email_addr, user.notification_subject_line(event_type), user.summary_info)
  end

  def send_msg(email_addr, subject, body)
    mail(from: 'AACT <aact@ctti-clinicaltrials.org>', to: email_addr, subject: subject, body: body)
  end

  def self.admin_addresses
    ['sheri.tibbs@duke.edu','ctti-aact@duke.edu']
  end

end
