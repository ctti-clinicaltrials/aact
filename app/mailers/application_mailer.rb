class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('AACT_OWNER_EMAIL','ctti@aact.com')
  layout 'mailer'

  def self.admin_addresses
    AACT::Application::AACT_ADMIN_EMAILS.split(",")
  end

end
