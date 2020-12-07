FactoryGirl.define do
  factory :search do
    save_tsv false
    query "MyString"
    grouping "MyString"
  end
  factory :reported_event_total do
    nct_id "MyString"
    ctgov_group_code "MyString"
    event_type "MyString"
    classification "MyString"
    subjects_affected 1
    subjects_at_risk 1
  end
  factory :category do
    nct_id "MyString"
    name "MyString"
    grouping "MyString"
  end
  factory :load_event, class: Support::LoadEvent do
  end
end
