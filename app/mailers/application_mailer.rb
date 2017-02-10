class ApplicationMailer < ActionMailer::Base
  default from: "AACT <mailgun@mg.aact-mail.org>"
  layout 'mailer'

  def self.send_simple_message
    RestClient.post "https://api:#{ENV['MAILGUN_API_KEY']}"\
    "@api.mailgun.net/v3/mg.aact-mail.org/messages",
    :from => "AACT <mailgun@mg.aact-mail.org>",
    :to => "sheri.tibbs@duke.edu, sheri.tibbs@gmail.com",
    :subject => "Hello",
    :text => "Testing some Mailgun awesomness!"
  end

end
