module Support
  class SupportBase < ActiveRecord::Base
    establish_connection(AACT::Application::AACT_BACK_DATABASE_URL)
    self.abstract_class = true
  end
end
