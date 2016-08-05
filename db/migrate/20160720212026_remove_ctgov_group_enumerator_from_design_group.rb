class RemoveCtgovGroupEnumeratorFromDesignGroup < ActiveRecord::Migration
  def change
    remove_column :design_groups, :ctgov_group_enumerator, :integer
  end
end
