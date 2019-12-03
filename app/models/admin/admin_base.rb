module Admin
  class AdminBase < ActiveRecord::Base
    establish_connection(AACT::Application::AACT_ADMIN_DATABASE_URL)
    self.abstract_class = true

    def self.database_exists?
      begin
        Admin::AdminBase.connection
      rescue ActiveRecord::NoDatabaseError
        false
      else
        true
      end
    end
  end
end
