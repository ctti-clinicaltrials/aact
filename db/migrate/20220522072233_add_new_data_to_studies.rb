class AddNewDataToStudies < ActiveRecord::Migration[6.0]
  def change
    add_column :studies, :source_class, :string
    add_column :studies, :delayed_posting, :string
    add_column :studies, :expanded_access_nctid, :string
    add_column :studies, :expanded_access_status_for_nctid, :string
    add_column :studies, :fdaaa801_violation, :string
  end
end
