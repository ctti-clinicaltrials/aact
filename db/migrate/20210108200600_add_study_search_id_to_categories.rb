class AddStudySearchIdToCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :study_search_id, :integer, foreign_key: true
  end
end
