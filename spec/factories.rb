FactoryGirl.define do
  factory :study_enrollment_type do
    name "MyString"
  end

  factory :study_history do
    nct_id "MyString"
    study_enrollment_type_id 1
    timestamp "2020-01-23 10:55:27"
    enrollment 1
  end

  factory :study do
    nct_id "MyString"
    enrollment 1
    enrollment_type "MyString"
  end

  factory :load_event, class: Support::LoadEvent do
  end
end
