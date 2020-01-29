class StudyEnrollmentType < ActiveRecord::Base
  has_many :study_histories
end
