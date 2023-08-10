class AddCiUpperLowerLimitRawToOutcomeAnalyses < ActiveRecord::Migration[6.0]
  def change
    add_column :outcome_analyses, :ci_upper_limit_raw, :string
    add_column :outcome_analyses, :ci_lower_limit_raw, :string
  end
end
