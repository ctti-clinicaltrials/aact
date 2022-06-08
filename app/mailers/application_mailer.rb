class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('AACT_OWNER_EMAIL','ctti@aact.com')
  layout 'mailer'
end
