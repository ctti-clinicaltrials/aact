module Admin
  class AdminBase < ActiveRecord::Base
    establish_connection(ENV["AACT_ADMIN_DATABASE_URL"])
    self.abstract_class = true
  end
end
