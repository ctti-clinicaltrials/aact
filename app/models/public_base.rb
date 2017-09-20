class PublicBase < ActiveRecord::Base
  establish_connection(ENV["PUBLIC_DATABASE_URL"])
  self.abstract_class = true
end
