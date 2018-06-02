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

  def self.send_event_notification(event_type, user)
    admin_addresses.each { |email_addr|
      event_notification(email_addr, user, event_type).try(:deliver_now)
    }
  end

  def event_notification(email_addr, user, event_type)
    @user=user
    mail(from: 'AACT <aact@ctti-clinicaltrials.org>', to: email_addr, subject: @user.notification_subject_line(event_type))
  end

end
