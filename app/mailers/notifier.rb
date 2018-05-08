class Notifier < ApplicationMailer

  def self.report_load_event(event)
    admin_addresses.each do |email|
      send_msg(email, event.subject_line, event.email_message).deliver_now
    end
  end

  def send_msg(email, subject, body)
    mail(from: 'AACT <aact@ctti-clinicaltrials.org>', to: email, subject: subject, body: body)
  end

  def self.admin_addresses
    ['sheri.tibbs@duke.edu','ctti-aact@duke.edu']
  end

  def instructions(user)
    @name = user.full_name
    @confirmation_url = confirmation_url(user)
    mail to: user.email, subject: 'Subscribe for Access to AACT (Aggregated Content of ClinicalTrials.gov)'
  end

end
