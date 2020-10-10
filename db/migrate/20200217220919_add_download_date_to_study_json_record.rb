class AddDownloadDateToStudyJsonRecord < ActiveRecord::Migration
  def change
    add_column 'support.study_json_records', :download_date, :string
  end
end
