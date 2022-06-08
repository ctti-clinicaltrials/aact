class ApplicationMailer < ActionMailer::Base
  default from: AACT::Application::AACT_OWNER_EMAIL
  layout 'mailer'
end
