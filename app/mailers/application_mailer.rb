class ApplicationMailer < ActionMailer::Base
  default from: "aact@ctti-clinicaltrials.org"
  layout 'mailer'

  def self.admin_addresses
    #['sheri.tibbs@duke.edu', 'ctti-aact@duke.edu']
    ['sheri.tibbs@duke.edu', 'sheri.tibbs@gmail.com']
  end

end
