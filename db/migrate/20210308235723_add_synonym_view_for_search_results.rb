class AddSynonymViewForSearchResults < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      create or replace view ctgov.categories 
      (id, nct_id, name, created_at, updated_at, grouping, study_search_id)
      as select * from ctgov.search_results;
    SQL
  end
  def down
    execute <<-SQL
      DROP VIEW IF EXISTS ctgov.categories CASCADE;
    SQL
  end
end
