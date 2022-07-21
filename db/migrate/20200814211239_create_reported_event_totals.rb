class CreateReportedEventTotals < ActiveRecord::Migration[4.2]
  def change
    create_table :reported_event_totals, if_not_exists: true do |t|
      t.string :nct_id, null: false
      t.string :ctgov_group_code, null: false
      t.string :event_type
      t.string :classification, null: false
      t.integer :subjects_affected
      t.integer :subjects_at_risk

      t.timestamps null: false
    end
  end
end
