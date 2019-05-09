module Admin
  class AdminBase < ActiveRecord::Base
    establish_connection(AACT::Application::AACT_ADMIN_DATABASE_URL)
    self.abstract_class = true
  end
end
