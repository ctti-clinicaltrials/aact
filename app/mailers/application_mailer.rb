class ApplicationMailer < ActionMailer::Base
  default from: "aact@ctti-clinicaltrials.org"
  layout 'mailer'

  def admin_addresses
    ['sheri.tibbs@duke.edu','ctti-aact@duke.edu']
  end

end
