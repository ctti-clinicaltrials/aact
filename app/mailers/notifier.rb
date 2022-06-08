class Notifier < ApplicationMailer
  def self.report_load_event(event)
    User.admin_emails.each { |email_addr|
      send_msg(email_addr, event).deliver_now
    }
  end

  def send_msg(email_addr, event)
    db = Util::DbManager.new
    @public_study_count = db.public_study_count
    @ctgov_count = ClinicalTrialsApi.number_of_studies
    @event = event
    @body = event.email_message
    mail(to: email_addr, subject: event.subject_line, from: 'ctti@duke.edu')
  end

  def report_diff(email)
    subj="Differences between ClinicalTrials.gov and AACT"
    mail(to: email, subject: subj, from: 'ctti@duke.edu')
  end
end
