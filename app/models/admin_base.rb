class AdminBase < ActiveRecord::Base
  establish_connection(ENV["DEV_ADMIN_DATABASE_URL"])
  self.abstract_class = true
end
