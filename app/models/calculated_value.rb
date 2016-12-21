class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

class CalculatedValue < ActiveRecord::Base
  belongs_to :study, :foreign_key => 'nct_id'

  def create_from(new_study)
    puts "OOOOOOOOOOOOOOOOOOO  CalculatedValue.create_from...."
    stime=Time.now
    self.study=new_study
    self.start_date                = study.start_month_year.try(:to_date)
    self.verification_date         = study.verification_month_year.try(:to_date)
    self.completion_date           = study.completion_month_year.try(:to_date)
    self.primary_completion_date   = study.primary_completion_month_year.try(:to_date)
    self.nlm_download_date         = get_download_date
    self.were_results_reported     = calc_were_results_reported
    self.has_us_facility           = calc_has_us_facility
    self.has_single_facility       = calc_has_single_facility
    self.number_of_facilities      = calc_number_of_facilities
    self.number_of_sae_subjects    = calc_number_of_sae_subjects
    self.number_of_nsae_subjects   = calc_number_of_nsae_subjects
    self.sponsor_type              = calc_sponsor_type
    self.registered_in_calendar_year = calc_registered_in_calendar_year
    self.actual_duration           = calc_actual_duration

    min_stuff=calc_age('min')
    self.minimum_age_num           = min_stuff.first
    self.minimum_age_unit          = min_stuff.last

    max_stuff=calc_age('max')
    self.maximum_age_num           = max_stuff.first
    self.maximum_age_unit          = max_stuff.first

    self.has_minimum_age          = !self.minimum_age_num.nil?
    self.has_maximum_age          = !self.maximum_age_num.nil?

    self.months_to_report_results = calc_months_to_report_results
    tm=Time.now - stime
    puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{self.nct_id} TOTAL LOAD TIME: #{tm}" if tm > 1
    self
  end

  def attribs
    {
      :start_date                  => study.start_month_year.try(:to_date),
      :verification_date           => study.verification_month_year.try(:to_date),
      :completion_date             => study.completion_month_year.try(:to_date),
      :primary_completion_date     => study.primary_completion_month_year.try(:to_date),
      :nlm_download_date           => get_download_date,

      :were_results_reported       => calc_results_reported,
      :has_us_facility             => calc_has_us_facility,
      :has_single_facility         => calc_has_single_facility,
      :number_of_facilities        => calc_number_of_facilities,
      :number_of_sae_subjects      => calc_number_of_sae_subjects,
      :number_of_nsae_subjects     => calc_number_of_nsae_subjects,
      :sponsor_type                => calc_sponsor_type,
      :registered_in_calendar_year => calc_registered_in_calendar_year,
    }
  end

  def calc_has_us_facility
    puts "HAS_US_FACILITY ========="
    !study.facilities.detect{|f|f.country=='United States'}.nil?
  end

  def calc_has_single_facility
    puts "HAS_SINGLE_FACILITY ========="
    study.facilities.size==1
  end

  def calc_age_unit(type)
    get_age(type).split(' ').last
  end

  def calc_has_age_limit(type)
    xtime=Time.now
    result=!calc_age(type).nil?
    tm=Time.now - xtime
    return result
  end

  def calc_age(type)
    age=get_age(type)
    age_first=age.split(' ').first
    age_number=age_first.to_i if age_first and age_first.is_i?
    age_unit=age.split(' ').last
    [age_number,age_unit]
  end

  def get_age(type)
    'min' ?  study.eligibility.minimum_age : study.eligibility.maximum_age
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
    puts "SAE SUBJECTS ========"
    xtime=Time.now
    result=study.reported_events.where('event_type = \'serious\' and subjects_affected is not null').sum(:subjects_affected)
    tm=Time.now - xtime
    puts "======================= number_of_sae_subjects  #{tm}    #{self.nct_id}" if tm > 1
    return result
  end

  def calc_number_of_nsae_subjects
    puts "NSAE SUBJECTS ========"
    xtime=Time.now
    result=nil
    result=study.reported_events.where('event_type != \'serious\' and subjects_affected is not null').sum(:subjects_affected)
    tm=Time.now - xtime
    puts "======================= number_of_nsae_subjects  #{tm}    #{self.nct_id}" if tm > 1
    return result
  end

  def calc_registered_in_calendar_year
    study.first_received_date.year if study.first_received_date
  end

  def calc_number_of_facilities
    study.facilities.count
  end

  def calc_actual_duration
    if !self.primary_completion_date or !self.start_date
      return if !self.primary_completion_date or !self.start_date
    end
    if study.primary_completion_date_type != 'Actual'
      return if study.primary_completion_date_type != 'Actual'
    end
    ((self.primary_completion_date.to_time -  self.start_date.to_time)/1.month.second).to_i
  end

  def calc_were_results_reported
    self.study.outcomes.size > 0
  end

  def calc_months_to_report_results
    return if !self.study.primary_completion_month_year or !study.first_received_results_date
    return if self.study.primary_completion_date_type != 'Actual'
    return if self.study.first_received_results_date.nil?
    ((self.study.first_received_results_date.to_time - primary_completion_date.to_time)/1.month.second).to_i
  end
end
