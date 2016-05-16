class AddNewAndChangedToLoadEvent < ActiveRecord::Migration
  def change
    add_column :load_events, :new_studies, :integer
    add_column :load_events, :changed_studies, :integer
  end
end
