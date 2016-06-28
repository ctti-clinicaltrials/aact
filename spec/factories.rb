FactoryGirl.define do
  factory :study_xml_record do
  end

  factory :load_event, class: ClinicalTrials::LoadEvent do
  end

  factory :study do
    nct_id 'NCT123'
  end
end
