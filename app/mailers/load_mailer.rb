class LoadMailer < ApplicationMailer
  def send_notification(load_event)
    emails = ['garrett@sturdy.work']

    if ENV['EMAIL_DUKE_TEAM']
      emails << 'sheri.tibbs@duke.edu'
      emails << 'williamhoos@gmail.com'
    end

    @load_event = load_event

    emails.each do |email|
      mail(to: email, subject: 'Load completed!')
    end
  end
end
