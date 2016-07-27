class CreateFacilityInvestigators < ActiveRecord::Migration
  def change
    create_table :facility_investigators do |t|
      t.string :name
      t.string :role
      t.string :nct_id
      t.integer :facility_id
    end

    remove_column :facilities, :investigator_name
    remove_column :facilities, :investigator_role
  end
end
