namespace :indexes do
  desc 'show indexes and foreign keys'
  task :show, [:schema] => :environment do |t, args|
    with_search_path(args[:schema]) do
      StudyRelationship.study_models.each do |model|
        puts model.table_name.blue
        model.connection.indexes(model.table_name).each do |index|
          puts "  #{index.name} -> #{index.columns.join(', ')}"
        end
      end
    end
  end

  desc 'add constraints'
  task :add, [:schema] => :environment do |t, args|
    with_search_path(args[:schema]) do
      db = Util::DbManager.new(schema: args[:schema])
      db.add_constraints
    end
  end

  desc 'remove constraints'
  task :remove, [:schema] => :environment do |t, args|
    with_search_path(args[:schema]) do
      db = Util::DbManager.new(schema: args[:schema])
      db.remove_constraints
    end
  end
end