class LoadMailer < ApplicationMailer
  def self.send_notifications(load_event, errors)
    emails = ['sheri.tibbs@duke.edu']

    emails.each do |email|
      send_notification(email, load_event, errors).deliver_now
    end
  end

  def send_notification(email, load_event, errors)
    @load_event = load_event
    @errors = errors

    subject_line="AACT #{ENV['RAILS_ENV']} load completed with #{@errors.size} errors"
    mail(from: 'Daily Load <daily_load@aact2.org>', to: email, subject: subject_line)
  end
end
