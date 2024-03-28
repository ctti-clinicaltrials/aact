class CreateSearchResults < ActiveRecord::Migration[4.2]
  def change
    # if ActiveRecord::Base.connection.table_exists?('categories')
    #   drop_table :categories 
    # end
      create_table :search_results, if_not_exists: true do |t|
        t.string :nct_id, null: false
        t.string :name, null: false
        t.timestamp :last_modified, null: false

        t.timestamps null: false
      end
      # add_index :search_results, [:nct_id], unique: true unless index_exists?(:search_results, :nct_id)
      # add_index :search_results, [:name], unique: true unless index_exists?(:search_results, :name)

      add_index :search_results, [:nct_id, :name], unique: true unless index_exists?(:search_results, [:nct_id, :name])
    # end
  end
end
