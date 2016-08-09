class StudyValidator
  def initialize
    @conditions = [
      {
        nct_id: 'NCT00734539',
        columns_or_associated_objects: {
          outcomes: { count: 2 },
          brief_title: { to_s: 'Fluconazole Prophylaxis for the Prevention of Candidiasis in Infants Less Than 750 Grams Birthweight' },
          study_type: { to_s: 'Interventional' }
        }
      },
      {
        nct_id: 'NCT01076361',
        columns_or_associated_objects: {
          outcomes: { count: 1 },
          baseline_measures: { count: 13 },
          study_type: { to_s: 'Observational [Patient Registry]' }
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
          actual_result = study.send(key).send(method)
          if actual_result != expected_result
            error = {
              data_attribute: key,
              nct_id: study.nct_id,
              expected_result: expected_result,
              actual_result: actual_result
            }

            StudyValidationMailer.alert(error.to_json).deliver_now

            raise StudyValidatorError, "\nExpected: #{expected_result}\nActual: #{actual_result}"
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
