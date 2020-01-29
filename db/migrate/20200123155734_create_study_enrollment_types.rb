class CreateStudyEnrollmentTypes < ActiveRecord::Migration
  def change
    create_table :study_enrollment_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
