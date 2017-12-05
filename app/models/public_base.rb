class PublicBase < ActiveRecord::Base
  establish_connection(ENV["AACT_PUBLIC_DATABASE_URL"])
  self.abstract_class = true
end
