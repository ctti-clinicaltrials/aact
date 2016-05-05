class CreateResults < ActiveRecord::Migration
  def change

    create_table :result_contacts do |t|
      t.string :name_or_title
      t.string :organization
      t.string :phone
      t.string :email
      t.timestamps null: false
    end
    add_column :result_contacts, :nct_id, :string, references: :studies

    create_table :result_agreements do |t|
      t.string :pi_employee
      t.text   :agreement
      t.string :agreement_type
      t.timestamps null: false
    end
    add_column :result_agreements, :nct_id, :string, references: :studies

    create_table :baseline_measures do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :category
      t.string  :title
      t.text    :description
      t.string  :units
      t.string  :param
      t.string  :measure_value
      t.string  :lower_limit
      t.string  :upper_limit
      t.string  :dispersion
      t.string  :spread
      t.text    :measure_description
      t.timestamps null: false
    end
    add_column :baseline_measures, :nct_id, :string, references: :studies

    create_table :result_details do |t|
      t.text :recruitment_details
      t.text :pre_assignment_details
      t.timestamps null: false
    end
    add_column :result_details, :nct_id, :string, references: :studies

    create_table :milestones do |t|
      t.string  :period_title
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :title
      t.text    :description
      t.integer :participant_count
      t.timestamps null: false
    end
    add_column :milestones, :nct_id, :string, references: :studies
    add_column :milestones, :group_id, :integer, references: :groups

    create_table :drop_withdrawals do |t|
      t.string  :period_title
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :reason
      t.integer :participant_count
      t.timestamps null: false
    end
    add_column :drop_withdrawals, :nct_id, :string, references: :studies
    add_column :drop_withdrawals, :group_id, :integer, references: :groups

    create_table :outcomes do |t|
      t.string  :outcome_type
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.text    :group_title
      t.text    :group_description
      t.text    :title
      t.text    :description
      t.string  :measure
      t.text    :time_frame
      t.string  :safety_issue
      t.text    :population
      t.integer :participant_count
      t.timestamps null: false
    end
    add_column :outcomes, :nct_id, :string, references: :studies
    add_column :outcomes, :group_id, :integer, references: :groups

    create_table :outcome_measures do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :category
      t.text    :title
      t.text    :description
      t.string  :units
      t.string  :param
      t.string  :measure_value
      t.string  :lower_limit
      t.string  :upper_limit
      t.string  :dispersion
      t.string  :spread
      t.text    :measure_description
      t.timestamps null: false
   end
    add_column :outcome_measures, :nct_id, :string, references: :studies
    add_column :outcome_measures, :outcome_id, :integer, references: :outcomes
    add_column :outcome_measures, :group_id, :integer, references: :groups

    create_table :outcome_analyses do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :title
      t.string  :non_inferiority
      t.text    :non_inferiority_description
      t.decimal :p_value, :precision => 15, :scale => 10
      t.string  :param_type
      t.decimal :param_value, :precision => 15, :scale => 10
			t.string  :dispersion_type
      t.decimal :dispersion_value, :precision => 15, :scale => 10
      t.string  :ci_percent
      t.string  :ci_n_sides
      t.decimal :ci_lower_limit, :precision => 15, :scale => 10
      t.decimal :ci_upper_limit, :precision => 16, :scale => 8
      t.string  :method
      t.text    :description
      t.text    :group_description
      t.text    :method_description
      t.text    :estimate_description
      t.timestamps null: false
    end
    add_column :outcome_analyses, :nct_id, :string, references: :studies
    add_column :outcome_analyses, :outcome_id, :integer, references: :outcomes
    add_column :outcome_analyses, :group_id, :integer, references: :groups

    create_table :reported_events do |t|
      t.string   :ctgov_group_id
      t.integer  :ctgov_group_enumerator
      t.string   :group_title
      t.text     :group_description
      t.text     :description
      t.text     :time_frame
      t.string   :category
      t.string   :event_type
      t.string   :frequency_threshold
      t.string   :default_vocab
      t.string   :default_assessment
      t.string   :title
      t.integer  :subjects_affected
      t.integer  :subjects_at_risk
      t.integer  :event_count
      t.timestamps null: false
    end
    add_column :reported_events, :nct_id, :string, references: :studies

    create_table :reported_event_overviews do |t|
      t.string :time_frame
      t.text   :description
      t.timestamps null: false
    end
    add_column :reported_event_overviews, :nct_id, :string, references: :studies

    create_table :groups do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :group_type
      t.string  :title
      t.text    :description
      t.integer :participant_count
      t.integer :derived_participant_count
      t.timestamps null: false
    end
    add_column :groups, :nct_id, :string, references: :studies

    create_table :participant_flows do |t|
      t.text    :recruitment_details
      t.text    :pre_assignment_details
      t.timestamps null: false
    end
    add_column :participant_flows, :nct_id, :string, references: :studies

  end
end
