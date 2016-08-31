class StudyValidator
  attr_accessor :errors, :nct_id

  def initialize
    @errors = []
  end

  def run
    ValidationCriteria.study_ids.each{|id|
      @nct_id=id.to_s
      study = Study.find_by(nct_id: nct_id)
      study ? validate_study(study) : report_missing
    }
    if errors.present?
      StudyValidationMailer.send_alerts(errors)
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

  def report_missing
    errors << {nct_id: nct_id, validation_title: 'Missing Study'}
  end

  def validate_study(study)
    ValidationCriteria.for(nct_id).each{|label, actual_expected|
      actual=eval actual_expected.first
      expected=actual_expected.last
      if actual != expected
        errors << { nct_id: nct_id, validation_title: label, expected_result: expected, actual_result: actual }
      else
        true
      end
    }
  end

end
