module Admin
  class AdminBase < ActiveRecord::Base
    connects_to database: { writing: :admin, reading: :admin }
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
