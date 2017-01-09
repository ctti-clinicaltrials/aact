class LoadMailer < ApplicationMailer

  def self.send_notifications(load_event)
    emails = ['sheri.tibbs@duke.edu']
    emails.each do |email|
      send_notification(email, load_event).deliver_now
    end
  end

  def send_notification(email, load_event)
    subject_line="AACT #{ENV['RAILS_ENV']} load status: #{load_event.status}. Added: #{load_event.new_studies} Changed: #{load_event.changed_studies}"
    mail(from: '<ctti.dcri@gmail.com>', to: email, subject: subject_line, body: load_event.description)
  end
end
