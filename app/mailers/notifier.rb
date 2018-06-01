class Notifier < ApplicationMailer

  def self.report_load_event(event)
    admin_addresses.each { |email_addr|
      send_msg(email_addr, event.subject_line, event.email_message).deliver_now
    }
  end

  def send_msg(email_addr, subject, body)
    mail(from: 'AACT <aact@ctti-clinicaltrials.org>', to: email_addr, subject: subject, body: body)
  end

  def self.admin_addresses
    ['sheri.tibbs@duke.edu','ctti-aact@duke.edu']
  end

end
