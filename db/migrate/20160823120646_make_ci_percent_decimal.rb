class MakeCiPercentDecimal < ActiveRecord::Migration
  def change
    change_column :outcome_analyses, :ci_percent, :decimal
  end
end
