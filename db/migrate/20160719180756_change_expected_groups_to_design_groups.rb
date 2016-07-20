class ChangeExpectedGroupsToDesignGroups < ActiveRecord::Migration
  def change
    rename_table :expected_groups, :design_groups
  end
end
