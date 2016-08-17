class ChangeVariousColumnNames < ActiveRecord::Migration
  def change
    remove_column :eligibilities, :study_population, :string
    add_column :eligibilities, :population, :string
  end
end
