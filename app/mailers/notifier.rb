class Notifier < ApplicationMailer

  def self.report_event(event)
    admin_addresses.each do |email|
      send_msg(email, event).deliver_now
    end
  end

  def send_msg(email, event)
    title="AACT #{Rails.env.capitalize} #{event.event_type.try(:capitalize)} Load Notification."
    if event.processed.nil? or event.processed == 0
      subject_line="#{title} Nothing to load."
    else
      subject_line="#{title} Load Status: #{event.status}. Added: #{event.should_add} Updated: #{event.should_change} Total: #{event.processed}"
    end
    mail(from: 'AACT <aact@ctti-clinicaltrials.org>', to: email, subject: subject_line, body: event.email_message)
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
