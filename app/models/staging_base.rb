class StagingBase < ActiveRecord::Base
    connects_to database: { writing: :staging, reading: :staging }
    self.abstract_class = true
  end