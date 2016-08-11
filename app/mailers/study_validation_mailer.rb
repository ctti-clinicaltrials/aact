class StudyValidationMailer < ApplicationMailer
  def alert(error)
    emails = ['garrett@sturdy.work']

    if ENV['SEND_VALIDATION_ERRORS_TO_DUKE_TEAM']
      emails << 'sheri.tibbs@duke.edu'
      emails << 'williamhoos@gmail.com'
    end

    @error = JSON.parse(error).symbolize_keys

    emails.each do |email|
      mail(to: email, subject: 'Study data validation failed')
    end
  end
end
