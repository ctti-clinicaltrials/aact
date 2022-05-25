class CreateTableRetractions < ActiveRecord::Migration[6.0]
  def change
    create_table :table_retractions do |t|
      t.integer 'reference_id'
      t.string 'pmid'
      t.string 'source'
      t.string 'nct_id'
    end
  end
end
