class Notifier < ApplicationMailer

  def self.report_load_event(event)
    admin_addresses.each { |email_addr|
      send_msg(email_addr, event.subject_line, event.email_message).deliver_now
    }
  end

  def send_msg(email_addr, subject, body)
    @body = body
    mail(to: email_addr, subject: subject, from: 'ctti@duke.edu')
  end

end
