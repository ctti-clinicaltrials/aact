module Support
  class SupportBase < ActiveRecord::Base
    establish_connection(ENV["AACT_BACK_DATABASE_URL"])
    self.abstract_class = true
  end
end
