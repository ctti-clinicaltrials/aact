class StudyValidationMailer < ApplicationMailer
  def self.send_alerts(errors)
    emails = ['sheri.tibbs@duke.edu']

    emails.each do |email|
      alert(email, errors).deliver_now
    end
  end

  def alert(email, errors)
    @errors = errors
    mail(to: email, subject: 'Study data validation for new load failed!')
  end
end

