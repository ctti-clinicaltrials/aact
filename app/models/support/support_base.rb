module Support
  class SupportBase < ActiveRecord::Base
    self.abstract_class = true
  end
end
