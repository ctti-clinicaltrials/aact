class Eligibility < StudyRelationship

  belongs_to :study, foreign_key: 'nct_id'

  # Scope to get age values for given nct_ids
  scope :age_values, ->(nct_ids) {
    where(nct_id: nct_ids).select(:nct_id, :minimum_age, :maximum_age)
  }

  # Calculated properties for minimum and maximum age
  def minimum_age_num
    split_age(minimum_age).first
  end

  def minimum_age_unit
    split_age(minimum_age).last
  end

  def maximum_age_num
    split_age(maximum_age).first
  end

  def maximum_age_unit
    split_age(maximum_age).last
  end

  # TODO: why do we have gender, healthy_volunteers, max age, min age indexed?
  # TODO: default N/A for max and min age is redundant

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


  private

  def split_age(age)
    return [nil, nil] if age.blank?

    age_parts = age.split(' ')
    age_num_value = age_parts.first.to_i
    age_unit = normalize_unit(age_parts.last)
    [age_num_value, age_unit]
  end


  def normalize_unit(unit)
    unit.downcase.singularize
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