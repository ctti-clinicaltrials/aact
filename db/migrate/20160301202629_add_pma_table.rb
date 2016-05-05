class AddPmaTable < ActiveRecord::Migration
  def change
    create_table :pma_mappings do |t|
      t.string :unique_id
			t.integer :ct_pma_id
			t.string  :pma_number
			t.string  :supplement_number
      t.timestamps null: false
		end
    add_column :pma_mappings, :nct_id, :string, references: :studies

    create_table :pma_records do |t|
      t.string :unique_id
      t.string :pma_number
      t.string :supplement_number
      t.string :supplement_type
      t.string :supplement_reason
      t.string :applicant
      t.string :street_1
      t.string :street_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :zip_ext
      t.date   :last_updated
      t.date   :date_received
      t.date   :decision_date
      t.string :decision_code
      t.string :expedited_review_flag
      t.string :advisory_committee
      t.string :advisory_committee_description
			t.string :device_name
			t.string :device_class
      t.string :product_code
      t.string :generic_name
      t.string :trade_name
      t.string :medical_specialty_description
      t.string :docket_number
      t.string :regulation_number
      t.text   :fei_numbers
      t.text   :registration_numbers
      t.text   :ao_statement
      t.timestamps null: false
		end
    add_column :pma_records, :nct_id, :string, references: :studies

  end
end
