class CalculatedValue < ActiveRecord::Base
  belongs_to :study, :foreign_key => 'nct_id'

  def self.populate(nct_ids)
    calculations = initialize_calculations(nct_ids)
    perform_calculations(nct_ids, calculations)
    remove_existing_records(nct_ids)
    insert_calculated_values(calculations)
  end
  

  private

  
  def self.initialize_calculations(nct_ids)
    nct_ids.each_with_object({}) do |nct_id, hash| 
      hash[nct_id] = {
        nct_id: nct_id,
        nlm_download_date: nil, # TODO: remove from table - not used
        months_to_report_results: nil,
        actual_duration: nil,
        registered_in_calendar_year: nil,
        number_of_facilities: 0,
        has_single_facility: nil,
        has_us_facility: nil,
        minimum_age_num: nil,
        minimum_age_unit: nil,
        maximum_age_num: nil,
        maximum_age_unit: nil,
        were_results_reported: false,
        number_of_primary_outcomes_to_measure: nil,
        number_of_secondary_outcomes_to_measure: nil,
        number_of_other_outcomes_to_measure: nil,
        number_of_nsae_subjects: nil,
        number_of_sae_subjects: nil
      }
    end
  end


  def self.insert_calculated_values(calculations)
    columns = [
      :nct_id, :were_results_reported,
      :number_of_facilities, :has_single_facility, :has_us_facility,
      :minimum_age_num, :minimum_age_unit, :maximum_age_num, :maximum_age_unit,
      :months_to_report_results, :actual_duration, :registered_in_calendar_year,
      :number_of_sae_subjects, :number_of_nsae_subjects,
      :number_of_primary_outcomes_to_measure, :number_of_secondary_outcomes_to_measure, :number_of_other_outcomes_to_measure,
    ]
    CalculatedValue.import columns, calculations.values
  end


  # TODO: do calculations first and package this as one thing with insert
  def self.remove_existing_records(nct_ids)
    CalculatedValue.where(nct_id: nct_ids).delete_all
  end


  def self.perform_calculations(nct_ids, calculations)
    start_time = Time.now
    process_were_results_reported(nct_ids, calculations)
    process_facility_info(nct_ids, calculations)
    process_age_info(nct_ids, calculations)
    process_outcome_design_counts(nct_ids, calculations)
    process_event_subject_counts(nct_ids, calculations)
    process_dates(nct_ids, calculations)
    end_time = Time.now
    duration = end_time - start_time
    puts "#perform_calculations executed in #{duration} seconds".green
  end


  # TODO: use has_results api single property instead
  def self.process_were_results_reported(nct_ids, calculations)
    results = Outcome.where(nct_id: nct_ids).distinct.pluck(:nct_id)
    results.each { |nct_id| calculations[nct_id][:were_results_reported] = true }
  end


  def self.process_facility_info(nct_ids, calculations)
    facility_counts = Facility.facility_counts(nct_ids)
    us_facilities = Facility.us_facility_nct_ids(nct_ids)

    facility_counts.each do | nct_id, count |
      calculations[nct_id][:number_of_facilities] = count
      calculations[nct_id][:has_single_facility] = (count == 1)
      calculations[nct_id][:has_us_facility] = us_facilities.include?(nct_id)
    end
  end


  def self.process_age_info(nct_ids, calculations)
    results = Eligibility.age_values(nct_ids)
    results.each do |study|
      calculations[study.nct_id][:minimum_age_num] = study.minimum_age_num
      calculations[study.nct_id][:minimum_age_unit] = study.minimum_age_unit
      calculations[study.nct_id][:maximum_age_num] = study.maximum_age_num
      calculations[study.nct_id][:maximum_age_unit] = study.maximum_age_unit
    end
  end


  def self.process_dates(nct_ids, calculations)
    results = Study.study_dates_for_calculations(nct_ids)
    results.each do |study|
      calculations[study.nct_id][:months_to_report_results] = calculate_months_to_report_results(study)
      calculations[study.nct_id][:actual_duration] = calculate_actual_duration(study)
      calculations[study.nct_id][:registered_in_calendar_year] = calculate_registered_year(study)
    end
  end
  

  def self.process_outcome_design_counts(nct_ids, calculations)
    results = DesignOutcome.count_outcomes_by_type_for(nct_ids)
    results.each do |nct_id, counts|
      calculations[nct_id][:number_of_primary_outcomes_to_measure] = counts[:primary]
      calculations[nct_id][:number_of_secondary_outcomes_to_measure] = counts[:secondary]
      calculations[nct_id][:number_of_other_outcomes_to_measure] = counts[:other]
    end
  end


  def self.process_event_subject_counts(nct_ids, calculations)
    results = ReportedEvent.sum_subjects_by_event_type_for(nct_ids)
    results.each do |nct_id, counts|
      calculations[nct_id][:number_of_sae_subjects] = counts[:serious]
      calculations[nct_id][:number_of_nsae_subjects] = counts[:other]
    end
  end


  # TODO: reveiw the dates used for calculation after transition to new version of api
  def self.calculate_months_to_report_results(study)
    # TODO: do we need to acount Primary Completion Date Type to avoid calculation on Estimated dates?
    return nil if study.results_first_submitted_date.nil? || study.primary_completion_date.nil?
    ((study.results_first_submitted_date - study.primary_completion_date) / 30).to_i
  end


  def self.calculate_actual_duration(study)
    return nil if study.start_date.nil? || study.start_date_type == "ESTIMATED"
    return nil if study.primary_completion_date.nil? || study.primary_completion_date_type == "ESTIMATED"
    ((study.primary_completion_date - study.start_date) / 30).to_i
  end


  def self.calculate_registered_year(study)
    return nil if study.study_first_submitted_date.nil?
    study.study_first_submitted_date.year
  end
end
