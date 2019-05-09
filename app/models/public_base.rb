class PublicBase < ActiveRecord::Base
  establish_connection(AACT::Application::AACT_PUBLIC_DATABASE_URL)
  self.abstract_class = true
end
