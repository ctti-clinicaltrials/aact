class CreateSupportLoadIssues < ActiveRecord::Migration[6.0]
  def change
    create_table 'support.load_issues' do |t|
      t.references :load_event, foreign_key: true
      t.string     :nct_id
      t.string     :message
    end
  end
end
