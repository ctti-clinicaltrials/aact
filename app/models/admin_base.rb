class AdminBase < ActiveRecord::Base
  establish_connection(ENV["ADMIN_DATABASE_URL"])
  self.abstract_class = true
end
