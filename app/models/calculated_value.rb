class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

class CalculatedValue < ActiveRecord::Base
  belongs_to :study, :foreign_key => 'nct_id'

  def create_from(new_study)
    self.study=new_study
    assign_attributes(attribs) if !attribs.blank?
    self.actual_duration = calc_actual_duration
    self.months_to_report_results = calc_months_to_report_results
    self
  end

  def attribs
    {
      :start_date                  => study.start_month_year.to_date,
      :verification_date           => study.verification_month_year.to_date,
      :completion_date             => study.completion_month_year.to_date,
      :primary_completion_date     => study.primary_completion_month_year.to_date,
      :nlm_download_date           => get_download_date,
      :sponsor_type                => calc_sponsor_type,
      :were_results_reported       => calc_results_reported,
      :registered_in_calendar_year => calc_registered_in_calendar_year,
      :number_of_facilities        => calc_number_of_facilities,
      :number_of_sae_subjects      => calc_number_of_sae_subjects,
      :number_of_nsae_subjects     => calc_number_of_nsae_subjects,
      :has_us_facility             => calc_has_us_facility,
      :has_minimum_age             => calc_has_age_limit('min'),
      :has_maximum_age             => calc_has_age_limit('max'),
      :minimum_age_num             => calc_age('min'),
      :maximum_age_num             => calc_age('max'),
      :minimum_age_unit            => calc_age_unit('min'),
      :maximum_age_unit            => calc_age_unit('max'),
    }
  end

  def get_age(type)
    type=='min' ?  study.eligibility.minimum_age : study.eligibility.maximum_age
  end

  def calc_has_us_facility
    !study.facilities.detect{|f|f.country=='United States'}.nil?
  end

  def calc_age_unit(type)
    get_age(type).split(' ').last
  end

  def calc_has_age_limit(type)
    !calc_age(type).nil?
  end

  def calc_age(type)
    age=get_age(type)
    first_part=age.split(' ').first
    first_part.to_i if first_part and first_part.is_i?
  end

  def get_download_date
    dt=study.nlm_download_date_description.split('ClinicalTrials.gov processed this data on ').last
    dt.to_date if dt
  end

  def calc_sponsor_type
    return nil if study.lead_sponsors.size > 1
    val=study.lead_sponsors.first.try(:agency_class)
    return val if val=='Industry' or val=='NIH'
    study.collaborators.each{|c|return 'NIH' if c.agency_class=='NIH'}
    study.collaborators.each{|c|return 'Industry' if c.agency_class=='Industry'}
    return 'Other'
  end

  def calc_number_of_sae_subjects
    if ReportedEvent.fast_count_estimate(study.reported_events) > 0
      study.reported_events.where('event_type = \'serious\' and subjects_affected is not null').sum(:subjects_affected)
    end
  end

  def calc_number_of_nsae_subjects
    if ReportedEvent.fast_count_estimate(study.reported_events) > 0
      study.reported_events.where('event_type != \'serious\' and subjects_affected is not null').sum(:subjects_affected)
    end
  end

  def calc_registered_in_calendar_year
    study.first_received_date.year if study.first_received_date
  end

  def calc_number_of_facilities
    study.facilities.count
  end

  def calc_actual_duration
    return if !primary_completion_date or !start_date
    return if study.primary_completion_date_type != 'Actual'
    ((primary_completion_date.to_time -  start_date.to_time)/1.month.second).to_i
  end

  def calc_results_reported
    1 if Outcome.fast_count_estimate(study.reported_events) > 0
  end

  def calc_months_to_report_results
    return if !study.primary_completion_month_year or !study.first_received_results_date
    return if study.primary_completion_date_type != 'Actual'
    return if study.first_received_results_date.nil?
    ((study.first_received_results_date.to_time -  primary_completion_date.to_time)/1.month.second).to_i
  end
end
