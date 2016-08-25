class StudyValidationMailer < ApplicationMailer
  def self.send_alerts(errors)
    emails = ['garrett@sturdy.work']

    if ENV['EMAIL_DUKE_TEAM']
      emails << 'sheri.tibbs@duke.edu'
      emails << 'williamhoos@gmail.com'
    end


    emails.each do |email|
      alert(email, errors).deliver_now
    end
  end

  def alert(email, errors)
    @errors = errors
    mail(to: email, subject: 'Study data validation for new load failed!')
  end
end

