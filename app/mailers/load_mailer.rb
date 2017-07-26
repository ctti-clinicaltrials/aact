class LoadMailer < ApplicationMailer

  def self.send_notifications(load_event)
    emails = ['sheri.tibbs@duke.edu']
    emails.each do |email|
      send_notification(email, load_event).deliver_now
    end
  end

  def send_notification(email, load_event)
    subject_line="AACT #{Rails.env.capitalize} #{load_event.event_type.capitalize} Load: Status: #{load_event.status}. Add: #{load_event.should_add} Update: #{load_event.should_change} Studies processed:  #{load_event.processed}"
    mail(from: 'AACT <mailgun@mg.aact-mail.org>', to: email, subject: subject_line, body: load_event.description)
  end
end
