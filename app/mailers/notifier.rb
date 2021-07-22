class Notifier < ApplicationMailer
  def self.report_load_event(schema, event)
    admin_addresses.each { |email_addr|
      send_msg(schema, email_addr, "#{schema} - #{event.subject_line}", event.email_message).deliver_now
    }
  end

  def send_msg(schema, email_addr, subject, body)
    db = Util::DbManager.new
    @ctgov_count = ClinicalTrialsApi.number_of_studies
    @public_study_count = db.public_study_count(schema)
    @body = body
    @schema = schema
    mail(to: email_addr, subject: subject, from: 'ctti@duke.edu')
  end
end
