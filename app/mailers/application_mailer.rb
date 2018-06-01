class ApplicationMailer < ActionMailer::Base
  default from: "aact@ctti-clinicaltrials.org"
  layout 'mailer'

  def send_msg(email_addr, subject, body)
    mail(from: 'AACT <aact@ctti-clinicaltrials.org>', to: email_addr, subject: subject, body: body)
  end

  def admin_addresses
    ['sheri.tibbs@duke.edu','ctti-aact@duke.edu']
  end

  def self.admin_addresses
    ['sheri.tibbs@duke.edu','ctti-aact@duke.edu']
  end

end
