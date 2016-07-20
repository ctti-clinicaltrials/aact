class AddPlanToShareDescription < ActiveRecord::Migration
  def change
    add_column :studies, :plan_to_share_description, :string
  end
end
