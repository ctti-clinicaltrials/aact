class CalculatedValue < ActiveRecord::Base
  belongs_to :study, :foreign_key => 'nct_id'

  def self.populate(nct_ids)


    remove_existing_records(nct_ids)
    insert_or_update_initial_values(nct_ids)


    # Run the following methods to update the table
    self.ruby_methods.each{|method|
      log_execution_time(method, nct_ids)
    } 

  end

  # Method to log execution time of a query
  def self.log_execution_time(method, nct_ids)
    start_time = Time.now
    send(method, nct_ids)

    end_time = Time.now
    duration = end_time - start_time
    puts "#{method} executed in #{duration} seconds".green
  end


  # TODO: udpate method name
  def self.ruby_methods
    [
      :update_were_results_reported,
      :update_facility_info,
      :update_age_info,
      :update_outcome_counts,
      :update_event_subject_counts,
      :update_calculated_dates
    ]
  end

  private

  def self.remove_existing_records(nct_ids)
    CalculatedValue.where(nct_id: nct_ids).delete_all
  end

  def self.insert_or_update_initial_values(nct_ids)
    # TODO: consider adding default values for the columns
    records = nct_ids.map{|nct_id| {nct_id: nct_id}}
    CalculatedValue.import records
  end

  # TODO: use has_results api single property instead
  def self.update_were_results_reported(nct_ids)
    reported_nct_ids = Outcome.where(nct_id: nct_ids).distinct.pluck(:nct_id)
    # TODO: is default value false?
    CalculatedValue.where(nct_id: reported_nct_ids).update_all(were_results_reported: true)
  end

  def self.update_facility_info(nct_ids)
    # returns hash
    facility_counts = Facility.facility_counts(nct_ids)
    # TODO: try to avoid multiple queries to the same table
    us_facilities = Facility.us_facility_nct_ids(nct_ids)

    update = facility_counts.map do | nct_id, count |
      {
        nct_id: nct_id,
        number_of_facilities: count,
        has_single_facility: (count == 1),
        has_us_facility: us_facilities.include?(nct_id)
      }
    end

    columns = [:nct_id, :number_of_facilities, :has_single_facility, :has_us_facility]
    options = { on_duplicate_key_update: { 
      conflict_target: [:nct_id], 
      columns: [:number_of_facilities, :has_single_facility, :has_us_facility] 
      } 
    }

    CalculatedValue.import columns, update, options
  end

  def self.update_age_info(nct_ids)
    # returns an array of Eligibility objects
    age_values = Eligibility.age_values(nct_ids)

    # TODO: this can be moved to model
    updates = age_values.map do |eligibility|
      {
        nct_id: eligibility.nct_id,
        minimum_age_num: eligibility.minimum_age_num,
        minimum_age_unit: eligibility.minimum_age_unit,
        maximum_age_num: eligibility.maximum_age_num,
        maximum_age_unit: eligibility.maximum_age_unit
      }
    end
    # Define columns to match the keys in the updates hashes
    columns = [:nct_id, :minimum_age_num, :minimum_age_unit, :maximum_age_num, :maximum_age_unit]

    # do update on existing records
    options = {
      on_duplicate_key_update: {
        conflict_target: [:nct_id],
        columns: [:minimum_age_num, :minimum_age_unit, :maximum_age_num, :maximum_age_unit]
      }
    }
    CalculatedValue.import columns, updates, options
  end
  
  def self.update_calculated_dates(nct_ids)
    #<ActiveRecord::Relation [#
    #<Study nct_id: "NCT01596972", results_first_submitted_date: "2014-05-15", start_date_type: nil, start_date: "2012-06-30", primary_completion_date_type: "ACTUAL", primary_completion_date: "2013-03-31">, 
    #<Study nct_id: "NCT02987738", results_first_submitted_date: nil, start_date_type: "ACTUAL", start_date: "2017-02-09", primary_completion_date_type: "ACTUAL", primary_completion_date: "2017-12-19">,
    #<Study nct_id: "NCT04066023", results_first_submitted_date: "2022-04-04", start_date_type: "ACTUAL", start_date: "2019-10-03", primary_completion_date_type: "ACTUAL", primary_completion_date: "2021-04-14">
    #]>
    results = Study.study_dates_for_calculations(nct_ids)

    # array option - do hash instead?
    updates = results.map do |study|
      {
        nct_id: study.nct_id,
        months_to_report_results: calculate_months_to_report_results(study),
        actual_duration: calculate_actual_duration(study),
        registered_in_calendar_year: calculate_registered_year(study)
      }
    end
    # puts updates
    columns = [:nct_id, :months_to_report_results, :actual_duration, :registered_in_calendar_year]

    options = { on_duplicate_key_update: {
      conflict_target: [:nct_id],
      columns: [:months_to_report_results, :actual_duration, :registered_in_calendar_year]
      }
    }

    CalculatedValue.import columns, updates, options
  end

  def self.update_outcome_counts(nct_ids)
    # hash = {"id"=>{:primary=>nil, :secondary=>nil, ....}, 
    results = DesignOutcome.count_outcomes_by_type_for(nct_ids)

    updates = results.map do |nct_id, counts|
      {
        nct_id: nct_id,
        number_of_primary_outcomes_to_measure: counts[:primary],
        number_of_secondary_outcomes_to_measure: counts[:secondary],
        number_of_other_outcomes_to_measure: counts[:other]
      }
    end

    columns = [:nct_id, :number_of_primary_outcomes_to_measure, :number_of_secondary_outcomes_to_measure, :number_of_other_outcomes_to_measure]
    options = { on_duplicate_key_update: {
      conflict_target: [:nct_id],
      columns: [:number_of_primary_outcomes_to_measure, :number_of_secondary_outcomes_to_measure, :number_of_other_outcomes_to_measure]
      }
    }
    CalculatedValue.import columns, updates, options

    # nct_ids.each do |nct_id|
    #   counts = results[nct_id]
    #   CalculatedValue.where(nct_id: nct_id).update_all(
    #     number_of_primary_outcomes_to_measure: counts[:primary],
    #     number_of_secondary_outcomes_to_measure: counts[:secondary],
    #     number_of_other_outcomes_to_measure: counts[:other]
    #   )
    # end
  end

  def self.update_event_subject_counts(nct_ids)
    results = ReportedEvent.sum_subjects_by_event_type_for(nct_ids)
    # array [{:nct_id=>"NCT01596972", :serious=>nil, :other=>nil}, {:nct_id=>"NCT02987738", :serious=>nil, :other=>nil}, {:nct_id=>"NCT04066023", :serious=>nil, :other=>10}]
    # updates = results.map do |result|
    #   {
    #     nct_id: result[:nct_id],
    #     number_of_sae_subjects: result[:serious],
    #     number_of_nsae_subjects: result[:other]
    #   }
    # end


    # hash = {"NCT01596972"=>{:serious=>nil, :other=>nil}, "NCT02987738"=>{:serious=>nil, :other=>nil}, "NCT04066023"=>{:serious=>nil, :other=>10}}
    updates = results.map do |nct_id, counts|
      {
        nct_id: nct_id,
        number_of_sae_subjects: counts[:serious],
        number_of_nsae_subjects: counts[:other]
      }
    end

    columns = [:nct_id, :number_of_sae_subjects, :number_of_nsae_subjects]
    options = { on_duplicate_key_update: {
      conflict_target: [:nct_id],
      columns: [:number_of_sae_subjects, :number_of_nsae_subjects]
      }
    }

    CalculatedValue.import columns, updates, options
  end


  private


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
