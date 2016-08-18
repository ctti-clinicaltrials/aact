FactoryGirl.define do
  factory :id_information do
    nct_id "MyString"
    id_type "MyString"
    id_value "MyString"
  end
  
  factory :central_contact do
    nct_id "MyString"
    contact_type "MyString"
    name "MyString"
    phone "MyString"
    email "MyString"
  end

  factory :sanity_check do
  end

  factory :study_xml_record do
  end

  factory :load_event, class: ClinicalTrials::LoadEvent do
  end

  factory :study do
    nct_id 'NCT123'
  end

  factory :calculated_value do

  end

  factory :pma_mapping do

  end
end
