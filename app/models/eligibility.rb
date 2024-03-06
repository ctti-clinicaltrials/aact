class Eligibility < StudyRelationship
  add_mapping do
    {
      table: :eligibilities,
      root: [:protocolSection, :eligibilityModule],
      columns: [
        { name: :sampling_method, value: :samplingMethod },
        { name: :population, value: :studyPopulation},
        { name: :maximum_age, value: :maximumAge, default: 'N/A' },
        { name: :minimum_age, value: :minimumAge, default: 'N/A' },
        { name: :gender, value: :sex },
        { name: :gender_based, value: ->(val) { get_boolean(val['genderBased']) } },
        { name: :gender_description, value: :genderDescription },
        { name: :healthy_volunteers, value: :healthyVolunteers },
        { name: :criteria, value: :eligibilityCriteria },
        { name: :adult, value: ->(val) { val.dig('stdAges')&.include?('ADULT') } },
        { name: :child, value: ->(val) { val.dig('stdAges')&.include?('CHILD') } },
        { name: :older_adult, value: ->(val) { val.dig('stdAges')&.include?('OLDER_ADULT') } }
      ]
    }
  end

  STRING_BOOLEAN_MAP = {
    'y' => true,
    'yes' => true,
    'true' => true,
    't' => true,
    'n' => false,
    'no' => false,
    'false' => false,
    'f' => false
  }
  
  def self.get_boolean(val)
    case val
    when String
      STRING_BOOLEAN_MAP[val.downcase]
    when TrueClass, FalseClass
      return val
    else
      return nil
    end
  end
end