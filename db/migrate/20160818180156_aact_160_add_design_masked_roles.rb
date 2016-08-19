class Aact160AddDesignMaskedRoles < ActiveRecord::Migration
  def change
    add_column :designs, :subject_masked, :boolean
    add_column :designs, :caregiver_masked, :boolean
    add_column :designs, :investigator_masked, :boolean
    add_column :designs, :outcomes_assessor_masked, :boolean
  end
end
