class AddUnitsToParticipantFlow < ActiveRecord::Migration[6.0]
  def change
    add_column :participant_flows, :units_analyzed, :string
  end
end
