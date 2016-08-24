class Aact177RemoveTitleFromOutcomeAnalysis < ActiveRecord::Migration
  def change
    remove_column :outcome_analyses, :title
  end
end
