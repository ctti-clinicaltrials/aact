FactoryGirl.define do
  factory :study_json_record do
    study_batch ""
    studies_saved_at "2019-11-25 15:52:10"
  end
  factory :load_event, class: Support::LoadEvent do
  end
end
