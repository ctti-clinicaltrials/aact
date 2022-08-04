class AddStudySearchIdToSearchResults < ActiveRecord::Migration[4.2]
  def change
    add_column :search_results, :study_search_id, :integer, foreign_key: true unless column_exists? :search_results, :study_search_id
  end
end
