class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.boolean :save_tsv, null: false, default: false
      t.string :query, null: false
      t.string :grouping, null: false, default: ''

      t.timestamps null: false
    end
  end
end
