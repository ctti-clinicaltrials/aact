namespace :build do
    task covid_search: :environment do
        StudySearch.make_covid_search
    end
    task funder_type_search: :environment do
        StudySearch.make_funder_search
    end
    task causes_of_death_search: :environment do
        StudySearch.make_causes_of_death_search
    end
    task all_searches: :environment do
        StudySearch.populate_database
    end
    task :categories, [:days_back] => [ :environment ] do |t,args|
        StudySearch.execute(args[:days_back])
    end
end