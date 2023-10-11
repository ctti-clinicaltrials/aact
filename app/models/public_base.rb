class PublicBase < ActiveRecord::Base
  connects_to database: { writing: :public, reading: :public }
  self.abstract_class = true
end
