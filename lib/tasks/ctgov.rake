namespace :ctgov do
  desc 'example study from ctgov'
  task :example, [:field] => :environment do |t, args|
    output = ClinicalTrialsApi.field_values(args[:field])
    output = ClinicalTrialsApi.studies_with_field_value(args[:field], output.first)
    puts output
  end
end
  