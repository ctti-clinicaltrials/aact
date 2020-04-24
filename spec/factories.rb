FactoryGirl.define do
  factory :category do
    nct_id "MyString"
    name "MyString"
    last_modified "2020-04-24 14:02:06"
  end
  factory :load_event, class: Support::LoadEvent do
  end
end
