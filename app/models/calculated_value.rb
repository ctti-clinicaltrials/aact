class CalculatedValue < ActiveRecord::Base
  belongs_to :study, :foreign_key => 'nct_id'

  def create_from(new_study)
    self.study=new_study
    assign_attributes(attribs) if !attribs.blank?
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
      :actual_duration             => calc_actual_duration,
      :were_results_reported       => calc_results_reported,
      :months_to_report_results    => calc_months_to_report_results,
      :registered_in_calendar_year => calc_registered_in_calendar_year,
      :number_of_facilities        => calc_number_of_facilities,
      :number_of_sae_subjects      => calc_number_of_sae_subjects,
      :number_of_nsae_subjects     => calc_number_of_nsae_subjects,
    }
  end

  def get_download_date
    dt=study.nlm_download_date_description.split('ClinicalTrials.gov processed this data on ').last
    dt.to_date if dt
  end

  def calc_link_to_data
      if study.org_study_id.upcase[/^NIDA/]
        url="https://datashare.nida.nih.gov/protocol/#{study.org_study_id.gsub(' ','')}"
        results=""#Faraday.get(url).body
        url if !results.downcase.include?('page not found')
      else
        #protocol link.....
        #url="http://clinicalstudies.info.nih.gov/cgi/cs/processqry3.pl?sort=1&search=#{nct_id}&searchtype=0&patient_type=All&protocoltype=All&institute=%25&conditions=All"
        #results=Faraday.get(url).body
        #self.link_to_data=url if !results.downcase.include?('page not found')
        #end
      end
  end

  def calc_sponsor_type
    val=study.lead_sponsor.try(:agency_class)
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
    (primary_completion_date - start_date).to_f/365
  end

  def calc_results_reported
    1 if Outcome.fast_count_estimate(study.reported_events) > 0
  end

  def calc_months_to_report_results
    return nil if study.first_received_results_date.nil? or primary_completion_date.nil?
    ((study.first_received_results_date.to_time -  primary_completion_date.to_time)/1.month.second).to_i
  end

end
