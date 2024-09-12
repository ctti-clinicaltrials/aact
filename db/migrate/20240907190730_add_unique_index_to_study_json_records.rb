class AddUniqueIndexToStudyJsonRecords < ActiveRecord::Migration[6.0]
  def change
    add_index :study_json_records, [:nct_id, :version], unique: true
  end
end
