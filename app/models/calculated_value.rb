class CalculatedValue < ActiveRecord::Base
  belongs_to :study, :foreign_key => 'nct_id'

  def self.populate(nct_ids)

    # TODO: possibly validate nct_ids

    # Populate the table with initial values for the valid nct_ids
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


  def self.ruby_methods
    [
      :update_were_results_reported,
      :update_facility_info,
      :update_age_info,
      :update_months_to_report_results
    ]
  end

  private


  def self.insert_or_update_initial_values(nct_ids)
    # TODO: consider adding default values for the columns
    nct_ids.each do |nct_id|
      CalculatedValue.find_or_create_by(nct_id: nct_id)
    end
  end

  # TODO: use has_results api single property instead
  def self.update_were_results_reported(nct_ids)
    reported_nct_ids = Outcome.where(nct_id: nct_ids).distinct.pluck(:nct_id)
    # TODO: is default value false?
    CalculatedValue.where(nct_id: reported_nct_ids).update_all(were_results_reported: true)
  end

  def self.update_facility_info(nct_ids)
    facility_counts = Facility.facility_counts(nct_ids)
    # TODO: try to avoid multiple queries to the same table
    us_facility_ids = Facility.us_facility_nct_ids(nct_ids)

    # TODO: check for studies without facilities
    # TODO: facilities with no country defined - Null?
    facility_counts.each do |nct_id, count|
      has_single_facility = (count == 1)
      has_us_facility = us_facility_ids.include?(nct_id)
      CalculatedValue.where(nct_id: nct_id).update_all(
        number_of_facilities: count,
        has_single_facility: has_single_facility,
        has_us_facility: has_us_facility
        )
    end
  end

  def self.update_age_info(nct_ids)
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

    updates.each do |age_info|
      CalculatedValue.where(nct_id: age_info[:nct_id]).update_all(
        minimum_age_num: age_info[:minimum_age_num],
        minimum_age_unit: age_info[:minimum_age_unit],
        maximum_age_num: age_info[:maximum_age_num],
        maximum_age_unit: age_info[:maximum_age_unit]
      )
    end
  end

  def self.update_months_to_report_results(nct_ids)
    results_dates = Study.with_dates_for_report(nct_ids)

    updates = results_dates.map do |study|
      months_to_report_results = ((study.results_first_submitted_date - study.primary_completion_date) / 30).to_i
      { nct_id: study.nct_id, months_to_report_results: months_to_report_results }
    end

    updates.each do |update|
      CalculatedValue.where(nct_id: update[:nct_id]).update_all(months_to_report_results: update[:months_to_report_results])
    end
  end
end
