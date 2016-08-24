class StudyValidator
  def validate_studies
    study1 = Study.find_by(nct_id: 'NCT00734539')
    study2 = Study.find_by(nct_id: 'NCT01076361')
    study3 = Study.find_by(nct_id: 'NCT01090362')
    study4 = Study.find_by(nct_id: 'NCT00660179')
    study5 = Study.find_by(nct_id: 'NCT02687217')
    study6 = Study.find_by(nct_id: 'NCT01983111')
    study7 = Study.find_by(nct_id: 'NCT02028676')

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Outcome count',
      expected_result: 12,
      actual_result: study1.outcomes.count
    )

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Brief title',
      expected_result: 'Fluconazole Prophylaxis for the Prevention of Candidiasis in Infants Less Than 750 Grams Birthweight',
      actual_result: study1.brief_title
    )

    assert(
      nct_id: study1.nct_id,
      validation_title: 'Study type',
      expected_result: 'Interventional',
      actual_result: study1.study_type
    )

    # assert(
    #   nct_id: study1.nct_id,
    #   validation_title: 'Outcome Measured Value Dispersion Lower Limit',
    #   expected_result: '88',
    #   actual_result: study1.outcome_measured_values.fifth.dispersion_lower_limit
    # )
    #
    # assert(
    #   nct_id: study1.nct_id,
    #   validation_title: 'Outcome Measured Value Dispersion Upper Limit',
    #   expected_result: '128',
    #   actual_result: study1.outcome_measured_values.fifth.dispersion_upper_limit
    # )

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
      validation_title: 'Study type',
      expected_result: 'Observational [Patient Registry]',
      actual_result: study2.study_type
    )

    assert(
      nct_id: study3.nct_id,
      validation_title: 'Study type',
      expected_result: 'Observational',
      actual_result: study3.study_type
    )

#TODO: not getting title value, though one exists...
    # assert(
    #   nct_id: study4.nct_id,
    #   validation_title: 'Outcome Measured Value Title',
    #   expected_result: 'Summary of the First Causes of Morbidity or Mortality',
    #   actual_result: study4.outcome_measured_values.first.title
    # )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Description',
      expected_result: 'Morbidity or mortality events were defined as: a) Death; b) Atrial septostomy; c) Lung transplantation; d) Initiation of intravenous (i.v.) or subcutaneous prostanoids, or; e) Other worsening of pulmonary arterial hypertension (PAH). Other worsening of PAH was defined by the combined occurrence of all the following 3 events: At least 15% decrease in the 6 minute walk distance from baseline, confirmed by 2 tests performed on separate days, within 2 weeks. AND worsening of PAH symptoms including at least one of the following: a) Increase in WHO Functional Class (WHO FC), or no change in patients in WHO FC IV at baseline; b) Appearance or worsening of signs of right heart failure that did not respond to optimized oral diuretic therapy AND need for new treatment(s) for PAH that included the following: a) Oral or inhaled prostanoids; b) Oral phosphodiesterase inhibitors; c) Endothelin receptor antagonists (only after discontinuation of study treatment; d) i.v. diuretics',
      actual_result: study4.outcome_measured_values.first.description.gsub(/\n/," ")
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Units',
      expected_result: 'participants',
      actual_result: study4.outcome_measured_values.first.units
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Param Type',
      expected_result: 'Number',
      actual_result: study4.outcome_measured_values.first.param
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Category',
      expected_result: 'Lung transplantation',
      actual_result: study4.outcome_measured_values.first.category
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value CTgov Group Code',
      expected_result: 'O3',
      actual_result: study4.outcome_measured_values.first.ctgov_group_code
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Param Value',
      expected_result: '0',
      actual_result: study4.outcome_measured_values.first.param_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Title',
      expected_result: 'Number of Participants',
      actual_value: study4.outcome_measured_values.last.title
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Units',
      expected_result: 'participants',
      actual_value: study4.outcome_measured_values.last.units
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Param Type',
      expected_result: 'Number',
      actual_result: study4.outcome_measured_values.last.param
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value CTgov Group Code',
      expected_result: 'B4',
      actual_result: study4.outcome_measured_values.last.group_id
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Measured Value Param Value',
      expected_result: '742',
      actual_result: study4.outcome_measured_values.last.param_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Count',
      expected_result: 8,
      actual_result: study4.outcome_analyses.count
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Non Inferiority',
      expected_result: 'No',
      actual_result: study4.outcome_analyses.first.non_inferiority
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis P Value',
      expected_result: 0.2509,
      actual_result: study4.outcome_analyses.first.p_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Method',
      expected_result: 'Log Rank',
      actual_result: study4.outcome_analyses.first.method
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Param Type',
      expected_result: 'Hazard Ratio (HR)',
      actual_result: study4.outcome_analyses.first.param_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Param Value',
      expected_result: 0.771,
      actual_result: study4.outcome_analyses.first.param_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Percent',
      expected_result: 97.5,
      actual_result: study4.outcome_analyses.first.ci_percent
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI N Sides',
      expected_result: '2-Sided',
      actual_result: study4.outcome_analyses.first.ci_n_sides
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Lower Limit',
      expected_result: 0.464,
      actual_result: study4.outcome_analyses.first.ci_lower_limit
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Upper Limit',
      expected_result: 1.282,
      actual_result: study4.outcome_analyses.first.ci_upper_limit
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Non Inferiority Last',
      expected_result: 'No',
      actual_result: study4.outcome_analyses.last.non_inferiority
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis P Value Last',
      expected_result: 0.0108,
      actual_result: study4.outcome_analyses.last.p_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Method',
      expected_result: 'Log Rank',
      actual_result: study4.outcome_analyses.last.method
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Param Type',
      expected_result: 'Hazard Ratio (HR)',
      actual_result: study4.outcome_analyses.last.param_type
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis Param Value',
      expected_result: 0.704,
      actual_result: study4.outcome_analyses.last.param_value
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Percent',
      expected_result: 97.5,
      actual_result: study4.outcome_analyses.last.ci_percent
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI N Sides',
      expected_result: '2-Sided',
      actual_result: study4.outcome_analyses.last.ci_n_sides
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Lower Limit',
      expected_result: 0.516,
      actual_result: study4.outcome_analyses.last.ci_lower_limit
    )

    assert(
      nct_id: study4.nct_id,
      validation_title: 'Outcome Analysis CI Upper Limit',
      expected_result: 0.960,
      actual_result: study4.outcome_analyses.last.ci_upper_limit
    )

    # assert(
    #   nct_id: study4.nct_id,
    #
    # )

    # assert(
    #   nct_id: study5.nct_id,
    #   validation_title: 'Outcome Measured Value Title',
    #   expected_result: 'Number of Participants',
    #   actual_result: study5.outcome_measured_values.last.title
    # )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Category',
      expected_result: 'Not required',
      actual_result: study5.outcome_measured_values.first.category
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Title',
      expected_result: 'Number of Patients Requiring Additional Treatment',
      actual_result: study5.outcome_measured_values.first.title
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Description',
      expected_result: 'Requirement of antipyretics; increased dose/ duration of antibiotic usage other than standard protocol; need for change to higher antibiotics; requirement of drainage procedures for pus/ wound infections; requirement for additional dressing sessions',
      actual_result: study5.outcome_measured_values.first.description
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Units',
      expected_result: 'participants',
      actual_result: study5.outcome_measured_values.first.units
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Ctgov Group Code',
      expected_result: 'O2',
      actual_result: study5.outcome_measured_values.first.ctgov_group_code
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Param Type',
      expected_result: 'Number',
      actual_result: study5.outcome_measured_values.first.param_type
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Dispersion Type',
      expected_result: 'Standard Deviation',
      actual_result: study5.outcome_measured_values.first.dispersion_type
    )

    # assert(
    #   nct_id: study5.nct_id,
    #   validation_title: 'Outcome Measured Value Dispersion Value',
    #   expected_result: '',
    #   actual_result: study5.outcome_measured_values.first.dispersion_value
    # )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Measured Value Param Value',
      expected_result: 30.0,
      actual_result: study5.outcome_measured_values.first.param_value
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Analysis Other P Value',
      expected_result: 0.5,
      actual_result: study5.outcome_analyses.first.p_value
    )

    assert(
      nct_id: study5.nct_id,
      validation_title: 'Outcome Analysis Method',
      expected_result: 'Chi-squared',
      actual_result: study5.outcome_analyses.first.method
    )

    assert(
      nct_id: study6.nct_id,
      validation_title: 'Outcome Analysis Non Inferiority Description',
      expected_result: 'In the PP set, for a non-inferiority test of the reduction in the pain intensity score from Visit 1 (Baseline) to Week 6 of treatment, the lower limit of the 97.5% onesided confidence interval was compared to a clinical non-inferiority margin, -1.5.',
      actual_result: study6.outcome_analyses.first.non_inferiority_description
    )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Outcome Analysis Method Description',
      expected_result: 'Generalised estimating equation with independent correlation structure and robust standard errors, calculated over all post-randomization visit weeks',
      actual_result: study7.outcome_analyses.first.method_description
    )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Outcome Analysis Estimate Description',
      expected_result: 'Hazard ratio is stop vs continue',
      actual_result: study7.outcome_analyses.second.estimate_description
    )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Reported Event Description',
      expected_result: 'Children were reviewed by a doctor at every scheduled doctor visit, as well as additional visits, and prompts on the doctor follow-up CRF asked about new/worsening/resolved Serious Adverse Events and Grade 3 or 4 Adverse Events.',
      actual_result: study7.reported_events.first.description
    )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Reported Event Time Frame',
      expected_result: 'LCM vs CDM and induction-maintenance: median 4 years (maximum 5 years); for randomizations; once vs twice daily: median 2 years (maximum 2.6 years); cotrimoxazole: median 2 years (maximum 2.5 years)',
      actual_result: study7.reported_events.first.time_frame
    )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Event Type',
    #   expected_result: '',
    #   actual_result:
    # )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Reported Event Default Vocab',
      expected_result: 'Trial-specific',
      actual_result: study7.reported_events.first.default_vocab
    )

    assert(
      nct_id: study7.nct_id,
      validation_title: 'Reported Event Default Assessment',
      expected_result: 'Systematic Assessment',
      actual_result: study7.reported_events.first.default_assessment
    )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Subjects Affected',
    #   expected_result: '',
    #   actual_result:
    # )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Subjects At Risk',
    #   expected_result: '',
    #   actual_result:
    # )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Event Count',
    #   expected_result: ,
    #   actual_result:
    # )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Ctgov Group Code',
    #   expected_result: ,
    #   actual_result:
    # )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Organ System',
    #   expected_result: 'Skin and subcutaneous tissue disorders',
    #   actual_result: study7.reported_events.first.category
    # )

    # assert(
    #   nct_id: study7.nct_id,
    #   validation_title: 'Reported Event Adverse Event Term',
    #   expected_result: '',
    #   actual_result:
    # )
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

      StudyValidationMailer.send_alerts(error.to_json)

      raise StudyValidatorError, "\nExpected: #{expected_result}\nActual: #{actual_result}"
    else
      true
    end
  end
end
