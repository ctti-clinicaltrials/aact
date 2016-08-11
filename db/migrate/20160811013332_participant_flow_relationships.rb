class ParticipantFlowRelationships < ActiveRecord::Migration
  def change

    remove_column  :milestones, :period_title, :string
    add_column     :milestones, :period, :string

    remove_column  :drop_withdrawals, :period_title, :string
    add_column     :drop_withdrawals, :period, :string

    remove_column  :result_groups, :group_type, :string
  end
end
