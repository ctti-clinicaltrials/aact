class DropDesignValidations < ActiveRecord::Migration
  def change
    drop_table :design_validations
  end
end
