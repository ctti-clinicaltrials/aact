FactoryBot.define do

  factory :background_job, class: BackgroundJob do
    user_id { 1 }
    status { "pending" }
    logs { "Logs string." }
    data { { 'query'=>'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 18;' } }
    url { "https://aact-dev.nyc3.digitaloceanspaces.com/ky8i7qmv3o8prmhwginfr4fxxnx1" }
  end

  factory :background_job_db_query, class: BackgroundJob::DbQuery do
    user_id { 2 }
    status { "pending" }
    logs { "Logs string." }
    data { { 'query'=>'SELECT nct_id, study_type, brief_title, enrollment, has_dmc, completion_date, updated_at FROM studies LIMIT 18;' } }
    url { "https://aact-dev.nyc3.digitaloceanspaces.com/ky8i7qmv3o8prmhwginfr4fxxnx1" }
  end

  factory :study_statistics_comparison, class: 'Support::StudyStatisticsComparison' do
    
  end

  factory :study_record do
  end

  factory :study_record_record do
  end
  
  factory :retraction do
  end

  factory :admin_user, class: 'Admin::User' do 
  end

  factory :file_record do
    filename { "MyString" }
    file_size { "" }
    file_type { "MyString" }
    string { "MyString" }
  end

  factory :verifier do
    
  end

  factory :study_search do

  end
  
  factory :study_json_record do
  end

  factory :search do
    save_tsv {false}
    query {"MyString"}
    grouping {"MyString"}
  end
  factory :reported_event_total do
    nct_id {"MyString"}
    ctgov_group_code {"MyString"}
    event_type {"MyString"}
    classification {"MyString"}
    subjects_affected { 1}
    subjects_at_risk {1}
  end
  factory :search_result do
    nct_id {"MyString"}
    name {"MyString"}
    grouping {"MyString"}
  end
  factory :load_event, class: Support::LoadEvent do
  end
end
