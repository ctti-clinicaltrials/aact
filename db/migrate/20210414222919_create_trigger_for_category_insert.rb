class CreateTriggerForCategoryInsert < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION category_insert_function() returns trigger as $category_insert_function$
        BEGIN
          INSERT INTO ctgov.search_results (id, nct_id, name, created_at, updated_at, grouping, study_search_id)

          VALUES (NEW.id, NEW.nct_id, NEW.name, NEW.created_at, NEW.updated_at, NEW.grouping, NEW.study_search_id);
          RETURN NEW;
        END;
        $category_insert_function$ language plpgsql;

      CREATE TRIGGER category_insert_trigger
      INSTEAD OF INSERT ON ctgov.categories
      FOR EACH ROW
      EXECUTE PROCEDURE category_insert_function();
      CREATE SEQUENCE categories_id_seq;
    SQL
  end

  def down
    execute <<-SQL
    DROP TRIGGER IF EXISTS category_insert_trigger ON categories CASCADE;
  SQL
  end
end
