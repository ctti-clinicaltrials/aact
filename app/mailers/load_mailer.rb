class LoadMailer < ApplicationMailer
  def self.send_notifications(load_event)
    emails = ['garrett@sturdy.work']

    if ENV['EMAIL_DUKE_TEAM']
      emails << 'sheri.tibbs@duke.edu'
      emails << 'williamhoos@gmail.com'
      emails << 'nancy.walden@duke.edu'
    end

    emails.each do |email|
      send_notification(email, load_event).deliver_now
    end
  end

  def send_notification(email, load_event)
    @load_event = load_event

    mail(to: email, subject: 'Load completed!')
  end
end
