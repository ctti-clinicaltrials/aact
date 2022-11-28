class AddDropWithdrawToParticipantFlows < ActiveRecord::Migration[6.0]
  def change
    add_column :drop_withdrawals, :drop_withdraw_comment, :string
    add_column :drop_withdrawals, :reason_comment, :string
    add_column :drop_withdrawals, :count_units, :integer
  end
end
