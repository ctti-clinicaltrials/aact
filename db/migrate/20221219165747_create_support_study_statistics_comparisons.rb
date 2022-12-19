class CreateSupportStudyStatisticsComparisons < ActiveRecord::Migration[6.0]
  def change
    create_table 'support.study_statistics_comparisons' do |t|
      t.string :ctgov_selector
      t.string :query
    end
  end
end
