class StudyValidator
  def initialize
    @conditions = [
      {
        nct_id: 'NCT00734539',
        columns_or_associated_objects: {
          outcomes: { count: 24 },
          brief_title: { to_s: 'Fluconazole Prophylaxis for the Prevention of Candidiasis in Infants Less Than 750 Grams Birthweight' }
        }
      },
      {
        nct_id: 'NCT01076361',
        columns_or_associated_objects: {
          outcomes: { count: 1 },
          baseline_measures: { count: 13 }
        }
      }
    ]
  end

  def validate_studies
    @conditions.each do |condition|
      study = Study.find_by(nct_id: condition[:nct_id])

      raise StudyValidatorError, 'Missing study!'  unless study.present?

      condition[:columns_or_associated_objects].each do |key, value|

        value.each do |method, expected_result|
          if study.send(key).send(method) != expected_result
            raise StudyValidatorError
          end
        end

      end

    end

    true
  end

  class StudyValidatorError < StandardError
    def initialize(msg='Study validation failed')
      super
    end
  end
end
