class StudyHistory < ActiveRecord::Base
  belongs_to :study_enrollment_type

  self.table_name = "historical.study_histories"
end
