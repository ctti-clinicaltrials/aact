class RemoveLinkToStudyDataFromCalculatedValues < ActiveRecord::Migration
  def change
    remove_column :calculated_values, :link_to_study_data, :string
  end
end
