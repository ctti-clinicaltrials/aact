namespace :ctgov do
    task :example, [:field] => :environment do |t, args|
      x = ClinicalTrialsApi.field_values(args[:field])
      pp x
    end
  
    task :example2, [:field, :value] => :environment do |t, args|
     x = ClinicalTrialsApi.studies_with_field_value(*args)
     pp x
    end
  end
  