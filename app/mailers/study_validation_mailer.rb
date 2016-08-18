class StudyValidationMailer < ApplicationMailer
  def self.send_alerts(error)
    emails = ['garrett@sturdy.work']

    if ENV['EMAIL_DUKE_TEAM']
      emails << 'sheri.tibbs@duke.edu'
      emails << 'williamhoos@gmail.com'
    end


    emails.each do |email|
      alert(email, error).deliver_now
    end
  end

  def alert(email, error)
    @error = JSON.parse(error).symbolize_keys
    mail(to: email, subject: 'Study data validation for new load failed!')
  end
end

