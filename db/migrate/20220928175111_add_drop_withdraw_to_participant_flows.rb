class AddDropWithdrawToParticipantFlows < ActiveRecord::Migration[6.0]
  def change
    add_column :participant_flows, :drop_withdraw_comment, :string
    add_column :participant_flows, :reason_comment, :string
    add_column :participant_flows, :count_units, :integer
  end
end
