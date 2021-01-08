namespace :build do
    task :covid_search do
        StudySearch.make_covid_search
    end
    task :funder_type_search do
        StudySearch.make_funder_search
    end
    task :causes_of_death_search do
        StudySearch.make_causes_of_death_search
    end
    task :all_searches do
        StudySearch.populate_database
    end
end