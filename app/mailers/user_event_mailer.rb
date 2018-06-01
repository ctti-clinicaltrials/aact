class UserEventMailer < ApplicationMailer

  def report_user_backup(event)
    @event=event
    @files=[]
    @event.file_names.delete(' ').split(',').each {|f|
      attachments[f.split('/').last] = File.read(f)
      @files << {
        :file_name => f.split('/').last,
        :file => File.read(f)
      }
    }
    admin_addresses.each { |email_addr|
      mail(to: email_addr, subject: @event.subject_line)
    }
  end

  def self.report_user_event(event_type, user)
    admin_addresses.each { |email_addr| send_user_event_msg(email_addr, user, event_type).deliver_now }
  end

  def send_user_event_msg(email_addr, user, event_type)
    send_msg(email_addr, user.notification_subject_line(event_type), user.summary_info)
  end

end
