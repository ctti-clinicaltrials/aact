class UserMailer < ApplicationMailer

  def self.send_backup_notification(event)
    admin_addresses.each { |email_addr|
      backup_notification(email_addr, event).deliver_now
    }
  end

  def backup_notification(email, event)
    @event=event
    @files=[]
    @event.file_names.delete(' ').split(',').each {|f|
      attachments[f.split('/').last] = File.read(f)
      @files << {
        :file_name => f.split('/').last,
        :file => File.read(f)
      }
    } if @event.file_names
    mail(from: 'AACT <aact@ctti-clinicaltrials.org>', to: email, subject: @event.subject_line)
  end

  def self.report_user_event(event_type, user)
    admin_addresses.each { |email_addr| send_user_event_msg(email_addr, user, event_type).deliver_now }
  end

  def send_user_event_msg(email_addr, user, event_type)
    #  refactor this so that it uses the user_event.subject_line
    send_msg(email_addr, user.notification_subject_line(event_type), user.summary_info)
  end

  def send_msg(email_addr, subject, body)
    mail(from: 'AACT <aact@ctti-clinicaltrials.org>', to: email_addr, subject: subject, body: body)
  end

end
