class AddDownloadDateToStudyJsonRecord < ActiveRecord::Migration[4.2]
  def change
    add_column 'support.study_json_records', :download_date, :string
  end
end
