class AddActiveToStudySearches < ActiveRecord::Migration[6.0]
  def change
    add_column :study_searches, :active, :boolean
  end
end
