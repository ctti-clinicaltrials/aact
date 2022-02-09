class Notifier < ApplicationMailer
  def self.report_load_event(event)
    admin_addresses.each { |email_addr|
      send_msg(email_addr, event.subject_line, event.email_message).deliver_now
    }
  end

  def send_msg(email_addr, event)
    db = Util::DbManager.new
    @public_study_count = db.public_study_count
    @ctgov_count = ClinicalTrialsApi.number_of_studies
    @event = event
    @body = event.email_message
    mail(to: email_addr, subject: event.subject, from: 'ctti@duke.edu')
  end
end
