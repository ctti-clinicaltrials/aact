class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
			t.date    :start_date
			t.date    :end_date
			t.string  :sponsor_type
			t.string  :stat_category
			t.string  :stat_value
			t.integer :number_of_studies
      t.timestamps null: false
    end
  end
end
