class RemoveTitleFromDesignOutcomes < ActiveRecord::Migration
  def change
    remove_column :design_outcomes, :title
  end
end
