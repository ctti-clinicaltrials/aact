class CreateStudyHistories < ActiveRecord::Migration
  def change
    create_table :study_histories do |t|
      t.string :nct_id
      t.integer :study_enrollment_type_id
      t.datetime :timestamp
      t.integer :enrollment

      t.timestamps null: false
    end
  end
end
