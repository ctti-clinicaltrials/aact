FactoryGirl.define do
  factory :category do
    nct_id 1
    name "MyString"
    last_modified "2020-04-24 12:24:31"
  end
  factory :load_event, class: Support::LoadEvent do
  end
end
