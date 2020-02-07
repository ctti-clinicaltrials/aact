class StudyEnrollmentType < ActiveRecord::Base
  # Run the following command in the console to get the needed types of enrollments.
  # StudyEnrollmentType.create([{name: "Actual"}, {name: "Anticipated"}])
  has_many :study_histories

  self.table_name = "historical.study_enrollment_types"
end
