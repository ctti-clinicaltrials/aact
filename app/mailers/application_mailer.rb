class ApplicationMailer < ActionMailer::Base
  default from: ENV['AACT_OWNER_EMAIL']
  layout 'mailer'

  def self.admin_addresses
    ENV['AACT_ADMIN_EMAILS'].split(",")
  end

end
