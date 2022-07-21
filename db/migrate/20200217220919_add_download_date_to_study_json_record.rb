class AddDownloadDateToStudyJsonRecord < ActiveRecord::Migration[4.2]
  def change
    
    add_column 'support.study_json_records', :download_date, :string unless column_exists? 'support.study_json_records', :download_date
  end
end
