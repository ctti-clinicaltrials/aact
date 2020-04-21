class PublicBase < ActiveRecord::Base
  byebug
   establish_connection(AACT::Application::AACT_PUBLIC_DATABASE_URL)
  self.abstract_class = true
end
