class StudyValidator
  def initialize
    @errors = []
  end

  def validate_studies
    study1 = Study.find_by(nct_id: 'NCT00734539')
    study2 = Study.find_by(nct_id: 'NCT01076361')

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Outcome count',
      expected_result: 22,
      actual_result: study1.outcomes.count
    )

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Brief title',
      expected_result: 'Flnazole Prophylaxis for the Prevention of Candidiasis in Infants Less Than 750 Grams Birthweight',
      actual_result: study1.brief_title
    )

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Study type',
      expected_result: 'Interventional',
      actual_result: study1.study_type
    )

    assert(
      nct_id: study2.nct_id,
      validation_title: 'Outcome count',
      expected_result: 1,
      actual_result: study2.outcomes.count
    )

    assert(
      nct_id: study2.nct_id,
      validation_title: 'Baseline measure count',
      expected_result: 13,
      actual_result: study2.baseline_measures.count
    )

    assert(
      nct_id: study2.nct_id,
      validation_title: 'Baseline measure count',
      expected_result: 13,
      actual_result: study2.baseline_measures.count
    )

    assert(
      nct_id: study2.nct_id,
      validation_title: 'Study type',
      expected_result: 'Observational [Patient Registry]',
      actual_result: study2.study_type
    )


    if @errors.present?
      StudyValidationMailer.send_alerts(@errors)

      raise StudyValidatorError
    else
      true
    end
  end

  class StudyValidatorError < StandardError
    def initialize(msg='Study validation failed')
      super
    end
  end

  private

  def assert(nct_id:, expected_result:, actual_result:, validation_title:)
    if actual_result != expected_result
      error = {
        nct_id: nct_id,
        validation_title: validation_title,
        expected_result: expected_result,
        actual_result: actual_result
      }

      @errors << error
    else
      true
    end
  end
end
