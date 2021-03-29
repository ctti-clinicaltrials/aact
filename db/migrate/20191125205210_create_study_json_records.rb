class CreateStudyJsonRecords < ActiveRecord::Migration[4.2]
  def change
    create_table 'support.study_json_records' do |t|
      t.string :nct_id, null: false
      t.jsonb :content, null: false
      t.timestamp :saved_study_at

      t.timestamps null: false
    end
  end
end
