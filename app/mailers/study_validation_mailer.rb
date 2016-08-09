class StudyValidationMailer < ApplicationMailer
  def alert(error)
    emails = ['garrett@sturdy.work']

    @error = JSON.parse(error).symbolize_keys

    emails.each do |email|
      mail(to: email, subject: 'Study data validation failed')
    end
  end
end
