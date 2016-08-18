class ChangeStudyPopulationToPopulation < ActiveRecord::Migration
  def change
    rename_column :eligibilities, :study_population, :population
  end
end
