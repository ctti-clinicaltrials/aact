class ApplicationMailer < ActionMailer::Base
  default from: AACT::Application::AACT_OWNER_EMAIL
  layout 'mailer'

  def self.admin_addresses
    AACT::Application::AACT_ADMIN_EMAILS.split(",")
  end

end
