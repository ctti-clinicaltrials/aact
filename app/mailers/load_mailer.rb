class LoadMailer < ApplicationMailer
  def self.send_notifications(load_event)
    emails = ['sheri.tibbs@duke.edu']

    emails.each do |email|
      send_notification(email, load_event).deliver_now
    end
  end

  def send_notification(email, load_event)
    @load_event = load_event

    subject_line="AACT #{ENV['RAILS_ENV']} load completed with #{@load_event.errors.size} errors"
    mail(from: 'Daily Load <daily_load@aact2.org>', to: email, subject: subject_line, body: @load_event.description)
  end
end
