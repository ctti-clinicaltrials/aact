class AddVersionToStudyJsonRecord < ActiveRecord::Migration[6.0]
  def change
    add_column :study_json_records, :version, :string, default: 1
  end
end
