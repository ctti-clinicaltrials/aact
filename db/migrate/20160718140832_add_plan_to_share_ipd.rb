class AddPlanToShareIpd < ActiveRecord::Migration
  def change
    add_column :studies, :plan_to_share_ipd, :string
  end
end
