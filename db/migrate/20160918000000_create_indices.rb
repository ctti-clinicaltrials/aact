class CreateIndices < ActiveRecord::Migration

  def change

    add_index :studies, :nct_id
    add_index :reported_events, :nct_id
    add_index :reported_events, :event_type
    add_index :reported_events, :subjects_affected
    add_index :facilities, :nct_id
    add_index :outcomes, :nct_id
    add_index :outcome_measured_values, :title

  end

end
