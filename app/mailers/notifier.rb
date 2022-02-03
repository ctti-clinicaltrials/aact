class Notifier < ApplicationMailer
  def self.report_load_event(schema, event)
    admin_addresses.each { |email_addr|
      send_msg(email_addr, "#{event.subject_line}", event.email_message).deliver_now
    }
  end

  def send_msg(email_addr, subject, event)
    db = Util::DbManager.new
    @ctgov_count = ClinicalTrialsApi.number_of_studies
    @event = event
    @body = event.email_message
    mail(to: email_addr, subject: subject, from: 'ctti@duke.edu')
  end
end
