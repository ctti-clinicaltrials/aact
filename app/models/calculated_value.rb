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
      :start_date                  => study.start_month_year.try(:to_date),
      :verification_date           => study.verification_month_year.try(:to_date),
      :completion_date             => study.completion_month_year.try(:to_date),
      :primary_completion_date     => study.primary_completion_month_year.try(:to_date),
      :nlm_download_date           => get_download_date,
      :sponsor_type                => calc_sponsor_type,
      :were_results_reported       => calc_results_reported,
      :registered_in_calendar_year => calc_registered_in_calendar_year,
      :number_of_facilities        => calc_number_of_facilities,
      :number_of_sae_subjects      => calc_number_of_sae_subjects,
      :number_of_nsae_subjects     => calc_number_of_nsae_subjects,
      :has_us_facility             => calc_has_us_facility,
      :has_single_facility         => calc_has_single_facility,
      :has_minimum_age             => calc_has_age_limit('min'),
      :has_maximum_age             => calc_has_age_limit('max'),
      :minimum_age_num             => calc_age('min'),
      :maximum_age_num             => calc_age('max'),
      :minimum_age_unit            => calc_age_unit('min'),
      :maximum_age_unit            => calc_age_unit('max'),
    }
  end

  def get_age(type)
    stime=Time.now
    type=='min' ?  study.eligibility.minimum_age : study.eligibility.maximum_age
    puts "======================= get_age  #{Time.now - stime}"
    type
  end

  def calc_has_us_facility
    stime=Time.now
    result=!study.facilities.detect{|f|f.country=='United States'}.nil?
    puts "======================= has_us_facility  #{Time.now - stime}"
    return result
  end

  def calc_has_single_facility
    stime=Time.now
    result=study.facilities.size==1
    puts "======================= has_single_facility  #{Time.now - stime}"
    return result
  end

  def calc_age_unit(type)
    stime=Time.now
    result=get_age(type).split(' ').last
    puts "======================= age_unit  #{Time.now - stime}"
    return result
  end

  def calc_has_age_limit(type)
    stime=Time.now
    result=!calc_age(type).nil?
    puts "======================= has_age_limit  #{Time.now - stime}"
    return result
  end

  def calc_age(type)
    age=get_age(type)
    first_part=age.split(' ').first
    first_part.to_i if first_part and first_part.is_i?
  end

  def get_download_date
    stime=Time.now
    dt=study.nlm_download_date_description.split('ClinicalTrials.gov processed this data on ').last
    result=dt.to_date if dt
    puts "======================= download_date  #{Time.now - stime}"
    return result
  end

  def calc_sponsor_type
    stime=Time.now
    return nil if study.lead_sponsors.size > 1
    val=study.lead_sponsors.first.try(:agency_class)
    if val=='Industry' or val=='NIH'
      puts "======================= sponsor_type  #{Time.now - stime}"
      return val if val=='Industry' or val=='NIH'
    end
    study.collaborators.each{|c|return 'NIH' if c.agency_class=='NIH'}
    study.collaborators.each{|c|return 'Industry' if c.agency_class=='Industry'}
    puts "======================= sponsor_type  #{Time.now - stime}"
    return 'Other'
  end

  def calc_number_of_sae_subjects
    stime=Time.now
    if study.reported_events.size > 0
      result=study.reported_events.where('event_type = \'serious\' and subjects_affected is not null').sum(:subjects_affected)
    end
    puts "======================= number_of_sae_subjects  #{Time.now - stime}"
    return result
  end

  def calc_number_of_nsae_subjects
    stime=Time.now
    result=nil
    if study.reported_events.size > 0
      result=study.reported_events.where('event_type != \'serious\' and subjects_affected is not null').sum(:subjects_affected)
    end
    puts "======================= number_of_nsae_subjects  #{Time.now - stime}"
    return result
  end

  def calc_registered_in_calendar_year
    stime=Time.now
    result=nil
    result=study.first_received_date.year if study.first_received_date
    puts "======================= registered_in_calendar_year  #{Time.now - stime}"
    return result
  end

  def calc_number_of_facilities
    stime=Time.now
    result=study.facilities.count
    puts "======================= number of facilities  #{Time.now - stime}"
    return result
  end

  def calc_actual_duration
    stime=Time.now
    if !primary_completion_date or !start_date
      puts "======================= actual duration  #{Time.now - stime}"
      return if !primary_completion_date or !start_date
    end
    if study.primary_completion_date_type != 'Actual'
      puts "======================= actual duration  #{Time.now - stime}"
      return if study.primary_completion_date_type != 'Actual'
    end
    result=((primary_completion_date.to_time -  start_date.to_time)/1.month.second).to_i
    puts "======================= actual duration  #{Time.now - stime}"
    return result
  end

  def calc_results_reported
    stime=Time.now
    result=study.outcomes.size > 0
    puts "======================= actual duration  #{Time.now - stime}"
    return result
  end

  def calc_months_to_report_results
    stime=Time.now
    if !study.primary_completion_month_year or !study.first_received_results_date
      puts "======================= months to report results  #{Time.now - stime}"
      return if !study.primary_completion_month_year or !study.first_received_results_date
    end
    if study.primary_completion_date_type != 'Actual'
      puts "======================= months to report results  #{Time.now - stime}"
      return if study.primary_completion_date_type != 'Actual'
    end
    if study.first_received_results_date.nil?
      puts "======================= months to report results  #{Time.now - stime}"
      return if study.first_received_results_date.nil?
    end
    result=((study.first_received_results_date.to_time -  primary_completion_date.to_time)/1.month.second).to_i
    puts "======================= months to report results  #{Time.now - stime}"
    return result
  end
end
