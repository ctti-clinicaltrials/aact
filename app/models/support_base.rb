class SupportBase < ActiveRecord::Base
  establish_connection(ENV["AACT_SUPPORT_DATABASE_URL"])
  self.abstract_class = true
end
