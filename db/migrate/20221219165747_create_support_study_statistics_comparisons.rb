class CreateSupportStudyStatisticsComparisons < ActiveRecord::Migration[6.0]
  def change
    create_table 'support.study_statistics_comparisons' do |t|
      t.string :ctgov_selector
      # we could add these columns to help us autogenerate the instances_query & the unique_query
      # t.string :table
      # t.string :column
      # t.string :condition
      t.string :instances_query
      t.string :unique_query
    end
  end
end
