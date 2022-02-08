class CreateStudyRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :study_records do |t|
      t.string      :nct_id
      t.string      :content
      t.string      :sha
      t.timestamps
    end
    add_index :study_records, :nct_id, unique: true
  end
end
