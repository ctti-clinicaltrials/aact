class UserMailer < ApplicationMailer

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

end
