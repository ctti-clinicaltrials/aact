class CreateStudies < ActiveRecord::Migration
		#NOTE!!!  The study_id links are fake - It seems we need to create them for raremap to correctly create relationships
		# to the Study table, but it's the NCT_ID that is the actual study primary key.
		#  We need to remove these columns on the final version

  def change
    create_table :studies, {:id => false} do |t|
      t.string  :nct_id, primary: true
      t.string  :org_study_id
      t.string  :study_type
      t.string  :overall_status
      t.string  :phase
      t.string  :target_duration
      t.string  :study_source
      t.string  :limitations_and_caveats
      t.string  :delivery_mechanism
      t.string  :description
      t.string  :acronym
      t.integer :number_of_arms
      t.integer :number_of_groups
      t.integer :enrollment
      t.string  :enrollment_type
      t.string  :why_stopped
      t.boolean :has_expanded_access
      t.boolean :has_dmc
      t.boolean :is_section_801
      t.boolean :is_fda_regulated
      t.string  :biospec_retention
      t.text    :biospec_description
      t.text    :brief_title
      t.text    :official_title
      t.string  :link_to_study_data
    end
		execute "CREATE UNIQUE INDEX studies_nct_id ON studies(nct_id);"

    create_table :calculated_values do |t|
      t.string  :nct_id
      t.date    :start_date
      t.date    :verification_date
      t.date    :primary_completion_date
      t.date    :completion_date
      t.date    :nlm_download_date
      t.decimal :actual_duration, :precision => 5, :scale => 2
      t.integer :registered_in_calendar_year
      t.boolean :were_results_reported
      t.integer :months_to_report_results
      t.decimal :actual_duration, :precision => 5, :scale => 2
      t.integer :number_of_facilities
      t.integer :number_of_nsae_subjects
      t.integer :number_of_sae_subjects
      t.integer :enrollment
      t.string  :sponsor_type
    end
		execute "ALTER TABLE calculated_values ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :facilities do |t|
      t.string :nct_id
      t.string :name
      t.string :status
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :latitude
      t.string :longitude
    end
		execute "ALTER TABLE facilities ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :investigators do |t|
      t.string :nct_id
      t.integer :facility_id
      t.string :name
      t.string :role
    end
		execute "ALTER TABLE investigators ADD FOREIGN KEY(facility_id) REFERENCES facilities(id);"

    create_table :facility_contacts do |t|
      t.string :nct_id
      t.integer :facility_id
      t.string :type
      t.string :name
      t.string :phone
      t.string :email
    end
		execute "ALTER TABLE facility_contacts ADD FOREIGN KEY(facility_id) REFERENCES facilities(id);"

    create_table :design_groups do |t|
      t.string :nct_id
      t.string  :group_type
			t.string  :label
      t.string  :title
      t.text    :description
    end
		execute "ALTER TABLE design_groups ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :interventions do |t|
      t.string :nct_id
      t.string  :intervention_type
      t.string  :name
      t.text    :description
    end
		execute "ALTER TABLE interventions ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

		create_table :design_groups_interventions do |t|
		  t.string  :nct_id
		  t.integer :intervention_id
		  t.integer :design_group_id
	  end
		execute "ALTER TABLE design_groups_interventions ADD FOREIGN KEY(intervention_id) REFERENCES interventions(id);"
		execute "ALTER TABLE design_groups_interventions ADD FOREIGN KEY(design_group_id) REFERENCES design_groups(id);"

    create_table :intervention_other_names do |t|
      t.string :nct_id
      t.string  :name
    end
		execute "ALTER TABLE intervention_other_names ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :conditions do |t|
      t.string :nct_id
      t.string  :name
    end
		execute "ALTER TABLE conditions ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :keywords do |t|
      t.string :nct_id
      t.string :name
    end
		execute "ALTER TABLE keywords ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :browse_conditions do |t|
      t.string :nct_id
      t.string :mesh_term
    end
		execute "ALTER TABLE browse_conditions ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :browse_interventions do |t|
      t.string :nct_id
      t.string :mesh_term
    end
		execute "ALTER TABLE browse_interventions ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :design_outcomes do |t|
      t.string :nct_id
      t.string :outcome_type
      t.string :title
      t.string :measure
      t.string :time_frame
      t.string :safety_issue
      t.string :population
      t.text   :description
    end
		execute "ALTER TABLE design_outcomes ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :study_references do |t|
      t.string :nct_id
      t.text   :citation
      t.string :pmid
      t.string :reference_type
    end
		execute "ALTER TABLE study_references ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :responsible_parties do |t|
      t.string :nct_id
      t.string :responsible_party_type
      t.string :affiliation
      t.string :name
      t.string :title
    end
		execute "ALTER TABLE responsible_parties ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :design_validations do |t|
      t.string :nct_id
      t.string  :design_name
      t.string  :design_value
      t.string  :masked_role
    end
		execute "ALTER TABLE design_validations ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :designs do |t|
      t.string :nct_id
      t.string :masking
      t.string :masked_roles
      t.string :primary_purpose
      t.string :intervention_model
      t.string :endpoint_classification
      t.string :allocation
      t.string :time_perspective
      t.string :observational_model
      t.text   :description
    end
    execute "ALTER TABLE designs ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :location_countries do |t|
      t.string :nct_id
      t.string :name
      t.string :removed
    end
    execute "ALTER TABLE location_countries ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :sponsors do |t|
      t.string :nct_id
      t.string :sponsor_type
      t.string :agency
      t.string :agency_class
    end
    execute "ALTER TABLE sponsors ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :overall_officials do |t|
      t.string :nct_id
      t.string :name
      t.string :role
      t.string :affiliation
    end
    execute "ALTER TABLE overall_officials ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :central_contacts do |t|
      t.string :nct_id
      t.string :contact_type
      t.string :name
      t.string :phone
      t.string :email
    end
    execute "ALTER TABLE central_contacts ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :oversight_authorities do |t|
      t.string :nct_id
      t.string :name
    end
    execute "ALTER TABLE oversight_authorities ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :links do |t|
      t.string :nct_id
      t.text   :url
      t.text   :description
    end
    execute "ALTER TABLE links ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :id_information do |t|
      t.string :nct_id
      t.string  :id_type
      t.string  :id_value
		end
    execute "ALTER TABLE id_information ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :eligibilities do |t|
      t.string :nct_id
      t.string :sampling_method
      t.string :gender
      t.string :minimum_age
      t.string :maximum_age
      t.string :healthy_volunteers
      t.text   :study_population
      t.text   :criteria
    end
    execute "ALTER TABLE eligibilities ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :detailed_descriptions do |t|
      t.string :nct_id
      t.text :description
    end
    execute "ALTER TABLE detailed_descriptions ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"

    create_table :brief_summaries do |t|
      t.string :nct_id
      t.text :description
    end
    execute "ALTER TABLE brief_summaries ADD FOREIGN KEY(nct_id) REFERENCES studies(nct_id);"
	end

end
