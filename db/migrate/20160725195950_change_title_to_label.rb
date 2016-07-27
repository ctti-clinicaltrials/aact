class ChangeTitleToLabel < ActiveRecord::Migration
  def change
    rename_column :design_groups, :title, :label
  end
end
