FactoryBot.define do
  factory :support_load_issue, class: 'Support::LoadIssue' do
    
  end

  factory :study_record do
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
    study_batch {""}
    studies_saved_at {"2019-11-25 15:52:10"}
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
