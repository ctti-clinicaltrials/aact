class LoadMailer < ApplicationMailer

  def self.send_notifications(load_event)
    emails = ['sheri.tibbs@duke.edu']
    emails.each do |email|
      send_notification(email, load_event).deliver_now
    end
  end

  def send_notification(email, load_event)
    subject_line="AACT #{ENV['RAILS_ENV']} load status: #{load_event.status}. To add: #{load_event.should_add} To update: #{load_event.should_change} Total processed:  #{load_event.processed}"
    mail(from: '<ctti.dcri@gmail.com>', to: email, subject: subject_line, body: load_event.description)
  end
end
