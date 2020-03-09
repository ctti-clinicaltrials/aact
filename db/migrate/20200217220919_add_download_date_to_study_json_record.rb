class AddDownloadDateToStudyJsonRecord < ActiveRecord::Migration
  def change
    add_column 'ctgov.study_json_records', :download_date, :string
  end
end
