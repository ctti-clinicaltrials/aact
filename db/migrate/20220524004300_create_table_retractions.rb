class CreateTableRetractions < ActiveRecord::Migration[6.0]
  def change
    create_table :table_retractions do |t|
      t.integer 'reference_id'
      t.integer 'pmid'
      t.string 'source'
    end
  end
end
