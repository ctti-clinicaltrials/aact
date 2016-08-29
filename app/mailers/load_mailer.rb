class LoadMailer < ApplicationMailer
  def self.send_notifications(load_event, errors)
    emails = ['garrett@sturdy.work']

    if ENV['EMAIL_DUKE_TEAM']
      emails << 'sheri.tibbs@duke.edu'
      emails << 'williamhoos@gmail.com'
      emails << 'nancy.walden@duke.edu'
    end

    emails.each do |email|
      send_notification(email, load_event, errors).deliver_now
    end
  end

  def send_notification(email, load_event, errors)
    @load_event = load_event
    @errors = errors

    mail(from: 'Daily Load <daily_load@aact2.org>', to: email, subject: 'Load completed!')
  end
end
