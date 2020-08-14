FactoryGirl.define do
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
    last_modified "2020-04-24 14:02:06"
  end
  factory :load_event, class: Support::LoadEvent do
  end
end
