class UserMailer < ApplicationMailer

  def self.send_backup_notification(event)
    admin_addresses.each { |email_addr|
      backup_notification(email_addr, event).deliver_now
    }
  end

  def self.send_event_notification(event_type, user)
    admin_addresses.each { |email_addr|
      event_notification(email_addr, user, event_type).try(:deliver_now)
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
    mail(to: email, subject: "AACT #{Rails.env.capitalize} User Backups")
  end

  def event_notification(email_addr, user, event_type)
    @user=user
    subj="AACT #{Rails.env.capitalize} user #{event_type}: #{@user.full_name}"
    mail(to: email_addr, subject: subj)
  end

end
