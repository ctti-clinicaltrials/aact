class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies, {:id => false} do |t|
      t.string :nct_id, primary: true

      t.date :start_date
      t.date :first_received_date
      t.date :verification_date
      t.date :last_changed_date
      t.date :primary_completion_date
      t.date :completion_date
      t.date :first_received_results_date
      t.date :download_date

      t.string  :start_date_str
      t.string  :first_received_date_str
      t.string  :verification_date_str
      t.string  :last_changed_date_str
      t.string  :primary_completion_date_str
      t.string  :completion_date_str
      t.string  :first_received_results_date_str
      t.string  :download_date_str
      t.string  :completion_date_type
      t.string  :primary_completion_date_type
      t.string  :org_study_id
      t.string  :secondary_id
      t.string  :study_type
      t.string  :overall_status
      t.string  :phase
      t.string  :target_duration
      t.integer :enrollment
      t.string  :enrollment_type
      t.string  :source
      t.string  :biospec_retention
      t.string  :limitations_and_caveats
      t.string  :delivery_mechanism
      t.string  :description
      t.string  :acronym
      t.integer :number_of_arms
      t.integer :number_of_groups
      t.string  :why_stopped
      t.boolean :has_expanded_access
      t.boolean :has_dmc
      t.boolean :is_section_801
      t.boolean :is_fda_regulated
      t.text    :brief_title
      t.text    :official_title
      t.text    :biospec_description
      t.timestamps null: false
		end
		add_index :studies, :nct_id
		add_index :studies, :study_type

    create_table :derived_values do |t|
      t.string  :sponsor_type
			t.decimal :actual_duration, :precision => 5, :scale => 2
      t.integer :enrollment
      t.boolean :results_reported
      t.integer :months_to_report_results
      t.integer :registered_in_fiscal_year
      t.integer :number_of_facilities
      t.integer :number_of_nsae_subjects
      t.integer :number_of_sae_subjects
      t.string  :study_rank
			t.string  :link_to_study_data
      t.timestamps null: false
    end
    add_column :derived_values, :nct_id, :string, references: :studies
		add_index :derived_values, :nct_id
		add_index :derived_values, :sponsor_type

    create_table :facilities do |t|
      t.string :name
      t.string :status
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :latitude
      t.string :longitude
      t.string :contact_name
      t.string :contact_phone
      t.string :contact_email
      t.string :contact_backup_name
      t.string :contact_backup_phone
      t.string :contact_backup_email
      t.text   :investigator_name
      t.text   :investigator_role
      t.timestamps null: false
    end
    add_column :facilities, :nct_id, :string, references: :studies
		add_index :facilities, :nct_id

    create_table :expected_groups do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :title
      t.string  :group_type
      t.text    :description
      t.timestamps null: false
    end
    add_column :expected_groups, :nct_id, :string, references: :studies
		add_index :expected_groups, :nct_id

    create_table :conditions do |t|
      t.string  :name
      t.timestamps null: false
    end
    add_column :conditions, :nct_id, :string, references: :studies
		add_index :conditions, :nct_id
		add_index :conditions, :name

    create_table :interventions do |t|
      t.string  :intervention_type
      t.string  :name
      t.text    :description
      t.timestamps null: false
    end
    add_column :interventions, :nct_id, :string, references: :studies
		add_index :interventions, :nct_id
		add_index :interventions, :name

    create_table :intervention_other_names do |t|
      t.string  :name
      t.timestamps null: false
    end
    add_column :intervention_other_names, :nct_id, :string, references: :studies
    add_column :intervention_other_names, :intervention_id, :string, references: :studies
		add_index :intervention_other_names, :nct_id
		add_index :intervention_other_names, :name
		add_index :intervention_other_names, :intervention_id

    create_table :intervention_arm_group_labels do |t|
      t.string  :label
      t.timestamps null: false
    end
    add_column :intervention_arm_group_labels, :nct_id, :string, references: :studies
    add_column :intervention_arm_group_labels, :intervention_id, :string, references: :studies
		add_index :intervention_arm_group_labels, :nct_id
		add_index :intervention_arm_group_labels, :intervention_id

    create_table :keywords do |t|
      t.string :name
      t.timestamps null: false
    end
    add_column :keywords, :nct_id, :string, references: :studies
		add_index :keywords, :nct_id
		add_index :keywords, :name

    create_table :browse_conditions do |t|
      t.string :mesh_term
      t.timestamps null: false
    end
    add_column :browse_conditions, :nct_id, :string, references: :studies
		add_index :browse_conditions, :nct_id

    create_table :browse_interventions do |t|
      t.string :mesh_term
      t.timestamps null: false
    end
    add_column :browse_interventions, :nct_id, :string, references: :studies
		add_index :browse_interventions, :nct_id

    create_table :expected_outcomes do |t|
      t.string :outcome_type
      t.text   :title
      t.text   :measure
      t.text   :time_frame
      t.string :safety_issue
      t.string :population
      t.text   :description
    end
    add_column :expected_outcomes, :nct_id, :string, references: :studies
		add_index :expected_outcomes, :nct_id

    create_table :study_references do |t|
      t.text   :citation
      t.string :pmid
      t.string :reference_type
    end
    add_column :study_references, :nct_id, :string, references: :studies
		add_index :study_references, :nct_id

    create_table :responsible_parties do |t|
      t.string :responsible_party_type
      t.text   :affiliation
      t.string :name
      t.string :title
    end
    add_column :responsible_parties, :nct_id, :string, references: :studies
		add_index :responsible_parties, :nct_id

    create_table :design_validations do |t|
			t.string  :design_name
			t.string  :design_value
			t.string  :masked_role
		end
    add_column :design_validations, :nct_id, :string, references: :studies
		add_index :design_validations, :nct_id

    create_table :designs do |t|
      t.text   :description
      t.string :masking
      t.string :masked_roles
      t.string :primary_purpose
      t.string :intervention_model
			t.string :endpoint_classification
			t.string :allocation
			t.string :time_perspective
			t.string :observational_model
    end
    add_column :designs, :nct_id, :string, references: :studies
		add_index :designs, :nct_id

    create_table :location_countries do |t|
      t.string :name
      t.string :removed
    end
    add_column :location_countries, :nct_id, :string, references: :studies
		add_index :location_countries, :nct_id
		add_index :location_countries, :name

    create_table :sponsors do |t|
      t.string :sponsor_type
      t.string :agency
      t.string :agency_class
    end
    add_column :sponsors, :nct_id, :string, references: :studies
		add_index :sponsors, :nct_id

    create_table :overall_officials do |t|
      t.string :name
      t.string :role
      t.string :affiliation
    end
    add_column :overall_officials, :nct_id, :string, references: :studies
		add_index :overall_officials, :nct_id

    create_table :oversight_authorities do |t|
      t.string :name
    end
    add_column :oversight_authorities, :nct_id, :string, references: :studies
		add_index  :oversight_authorities, :nct_id

    create_table :links do |t|
      t.text   :url
      t.text   :description
    end
    add_column :links, :nct_id, :string, references: :studies
		add_index  :links, :nct_id

    create_table :secondary_ids do |t|
      t.string :secondary_id
    end
    add_column :secondary_ids, :nct_id, :string, references: :studies
		add_index  :secondary_ids, :nct_id

    create_table :eligibilities do |t|
      t.string :sampling_method
      t.string :gender
      t.string :minimum_age
      t.string :maximum_age
      t.string :healthy_volunteers
      t.text   :study_population
      t.text   :criteria
    end
    add_column :eligibilities, :nct_id, :string, references: :studies
		add_index  :eligibilities, :nct_id

    create_table :detailed_descriptions do |t|
      t.text :description
    end
    add_column :detailed_descriptions, :nct_id, :string, references: :studies
		add_index  :detailed_descriptions, :nct_id

    create_table :brief_summaries do |t|
      t.text :description
    end
    add_column :brief_summaries, :nct_id, :string, references: :studies
		add_index  :brief_summaries, :nct_id

  end

end
