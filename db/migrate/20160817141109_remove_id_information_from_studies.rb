class RemoveIdInformationFromStudies < ActiveRecord::Migration
  def change
    remove_column :studies, :org_study_id, :string
    remove_column :studies, :secondary_id, :string
  end
end
