class AddStudySearchIdToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :study_search_id, :integer, foreign_key: true
  end
end
