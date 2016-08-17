class ChangeVariousColumnNames < ActiveRecord::Migration
  def change
    remove_column :eligibilities, :study_population, :string
    add_column :eligibilities, :population, :string
    remove_column :calculated_values, :results_reported, :boolean
    add_column :calculated_values, :were_results_reported, :boolean
    remove_column :studies, :plan_to_share_description, :string
    add_column :studies, :plan_to_share_ipd_description, :string
    remove_column :design_groups, :ctgov_group_code, :string
    remove_column :sponsors, :sponsor_type, :string
    add_column :sponsors, :lead_or_collaborator, :string
    remove_column :sponsors, :agency, :string
    add_column :sponsors, :name, :string

		drop_table :facility_investigators
		drop_table :facility_contacts

    create_table :facility_investigators do |t|
      t.string :name
      t.string :role
      t.string :nct_id
    end
    add_column  :facility_investigators, :facility_id, :integer, references: :facilities

    create_table :facility_contacts do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.string :contact_type
      t.string :nct_id
    end
    add_column  :facility_contacts, :facility_id, :integer, references: :facilities

  end
end
