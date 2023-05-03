namespace :ctgov do
  desc 'example study from ctgov'
  task :example, [:field] => :environment do |t, args|
    output = ClinicalTrialsApi.field_values(args[:field])
    output = ClinicalTrialsApi.studies_with_field_value(args[:field], output.first)
    puts output
  end

  desc 'from the studies that have missing values'
  task :find_missing, [:field, :table, :column] => :environment do |t, args|
    ctgov = ClinicalTrialsApi.field_values(args[:field])
    aact = PublicBase.connection.execute("SELECT DISTINCT(#{args[:column]}) AS col FROM #{args[:table]}").to_a.map{|k| k['col']}
    diff = ctgov - aact
    output = ClinicalTrialsApi.studies_with_field_value(args[:field], diff.first)
  end
end
  