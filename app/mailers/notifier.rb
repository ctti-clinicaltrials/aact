class Notifier < ApplicationMailer
  def self.report_load_event(schema, event)
    admin_addresses.each { |email_addr|
      send_msg(schema, email_addr, "#{schema} - #{event.subject_line}", event.email_message).deliver_now
    }
  end

  def send_msg(schema, email_addr, subject, body)
    db = Util::DbManager.new
    @ctgov_count = ClinicalTrialsApi.number_of_studies
    @public_study_count = db.public_study_count
    @body = body
    @schema = schema
    mail(to: email_addr, subject: subject, from: 'ctti@duke.edu')
  end

  def report_diff(email, link)
    link = https://aact.ctti-clinicaltrials.org/static/differences/study_statistics/verifier_differences_ctgov.csv
    
    subj="Differences between ClinicalTrials.gov and AACT"
    mail(to: email, subject: subj)
  end
end
