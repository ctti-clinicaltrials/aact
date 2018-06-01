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
      mail(to: email_addr, subject: @event.subject_line).deliver_now
    }
  end

  def report_user_event(event_type, user)
    admin_addresses.each { |email_addr|
      send_msg(email_addr, user.notification_subject_line(event_type)).deliver_now
    }
  end

  def send_msg(email_addr, subject)
    mail(to: email_addr, subject: subject)
  end

end
