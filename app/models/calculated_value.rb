class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

class CalculatedValue < ActiveRecord::Base
  belongs_to :study, :foreign_key => 'nct_id'

  def self.populate
    ActiveRecord::Base.connection.execute('REVOKE SELECT ON TABLE calculated_values FROM aact;')
    ActiveRecord::Base.connection.execute('TRUNCATE table calculated_values')
    ActiveRecord::Base.connection.execute("INSERT INTO calculated_values (
                 nct_id,
                 nlm_download_date
          )
          SELECT nct_id,
                 to_date(substring(nlm_download_date_description,43), 'Month DD,YYYY')
            FROM studies")

    self.sql_methods.each{|method|
      cmd='UPDATE calculated_values '+ CalculatedValue.send(method)
      ActiveRecord::Base.connection.execute(cmd)
    }
    self.save_downcased_mesh_terms
    ActiveRecord::Base.connection.execute("GRANT SELECT ON TABLE calculated_values TO aact")
  end

  def self.save_downcased_mesh_terms
    #  save a lowercase version of MeSH terms so they can be found without worrying about case
    ActiveRecord::Base.connection.execute("UPDATE browse_conditions SET downcase_mesh_term=lower(mesh_term);")
    ActiveRecord::Base.connection.execute("UPDATE browse_interventions SET downcase_mesh_term=lower(mesh_term);")
    ActiveRecord::Base.connection.execute("UPDATE keywords SET downcase_name=lower(name);")
    ActiveRecord::Base.connection.execute("UPDATE conditions SET downcase_name=lower(name);")
  end

  def self.sql_methods
    [
      :sql_for_registered_in_calendar_year,
      :sql_for_were_results_reported,
      :sql_for_has_single_facility,
      :sql_for_has_us_facility1,
      :sql_for_has_us_facility2,
      :sql_for_has_us_facility3,
      :sql_for_number_of_facilities,
      :sql_for_months_to_report_results,
      :sql_for_actual_duration,
      :sql_for_number_of_sae_subjects,
      :sql_for_number_of_nsae_subjects,
      :sql_for_minimum_age_num,
      :sql_for_minimum_age_unit,
      :sql_for_maximum_age_num,
      :sql_for_maximum_age_unit,
    ]

  end

  def self.sql_for_dates
    "INSERT INTO calculated_values (
                 nct_id,
                 nlm_download_date
          )
          SELECT nct_id,
                 to_date(substring(nlm_download_date_description,43), 'Month DD,YYYY')
            FROM studies"
  end

  def self.sql_for_registered_in_calendar_year
    "SET registered_in_calendar_year = x.res
       FROM ( SELECT nct_id, date_part('year', first_received_date) as res FROM studies ) x
      WHERE x.nct_id = calculated_values.nct_id"
  end

  def self.sql_for_were_results_reported
    "SET were_results_reported=true WHERE nct_id in (SELECT distinct nct_id FROM outcomes)"
  end

  def self.sql_for_has_single_facility
    "SET has_single_facility=true WHERE nct_id in (SELECT nct_id FROM facilities GROUP BY nct_id HAVING count(*)=1)"
  end

  def self.sql_for_has_us_facility1
    # FIRST:  defaut to false
    "SET has_us_facility=false"
  end

  def self.sql_for_has_us_facility2
    # SECOND: set to true if at least one facility is US
    "SET has_us_facility=true WHERE nct_id in (SELECT distinct nct_id FROM countries WHERE name='United States' AND removed IS NOT true)"
  end

  def self.sql_for_has_us_facility3
    # THIRD: studies that don't have countries defined, set to null
     "  SET has_us_facility=null WHERE nct_id in (
         SELECT distinct l.nct_id
           FROM studies l
      LEFT JOIN countries r
             ON (r.nct_id = l.nct_id AND r.removed IS NOT true)
          WHERE r.nct_id IS NULL)"
  end

  def self.sql_for_number_of_facilities
    "SET number_of_facilities = x.res FROM ( SELECT  nct_id, count(*) as res FROM facilities f GROUP BY nct_id) x WHERE x.nct_id = calculated_values.nct_id AND number_of_facilities is null"
  end

  def self.sql_for_months_to_report_results
    "SET months_to_report_results = x.res FROM ( SELECT  s.nct_id, (s.first_received_results_date - s.primary_completion_date)/30 as res FROM studies s, calculated_values c WHERE s.nct_id=c.nct_id) x WHERE x.nct_id = calculated_values.nct_id"
  end

  def self.sql_for_actual_duration
    "SET actual_duration = x.res FROM ( SELECT  nct_id, (primary_completion_date -  start_date)/30 as res
           FROM studies s
          WHERE s.primary_completion_date_type <> 'Anticipated'
            AND (s.start_date_type IS NULL OR s.start_date_type = 'Actual')
    ) x
      WHERE x.nct_id = calculated_values.nct_id"
  end

  def self.sql_for_number_of_sae_subjects
    "SET number_of_sae_subjects = x.res FROM ( SELECT re.nct_id, sum(re.subjects_affected) as res FROM reported_events re WHERE re.event_type='serious' GROUP BY re.nct_id) x WHERE x.nct_id = calculated_values.nct_id"
  end

  def self.sql_for_number_of_nsae_subjects
    "SET number_of_nsae_subjects = x.res FROM ( SELECT re.nct_id, sum(re.subjects_affected) as res FROM reported_events re WHERE re.event_type='other' GROUP BY re.nct_id) x WHERE x.nct_id = calculated_values.nct_id "
  end

  def self.sql_for_minimum_age_num
    "SET minimum_age_num = x.res FROM ( SELECT nct_id, substring(minimum_age from 1 for position(' ' in minimum_age))::integer as res FROM eligibilities WHERE minimum_age != 'N/A' AND minimum_age != '') x WHERE x.nct_id = calculated_values.nct_id"
  end

  def self.sql_for_maximum_age_num
    "SET maximum_age_num = x.res FROM ( SELECT nct_id, substring(maximum_age from 1 for position(' ' in maximum_age))::integer as res FROM eligibilities WHERE maximum_age != 'N/A' AND maximum_age != '') x WHERE x.nct_id = calculated_values.nct_id"
  end

  def self.sql_for_maximum_age_unit
    "SET maximum_age_unit = x.res FROM ( SELECT nct_id, substring(maximum_age from position(' ' in maximum_age)) as res FROM eligibilities WHERE maximum_age != 'N/A' AND maximum_age != '') x WHERE x.nct_id = calculated_values.nct_id"
  end

  def self.sql_for_minimum_age_unit
    "SET minimum_age_unit = x.res FROM ( SELECT nct_id, substring(minimum_age from position(' ' in minimum_age)) as res FROM eligibilities WHERE minimum_age != 'N/A' AND minimum_age != '') x WHERE x.nct_id = calculated_values.nct_id"
  end

  def create_from(new_study)
    stime=Time.now
    self.study=new_study
    self.has_us_facility           = calc_has_us_facility
    self.has_single_facility       = calc_has_single_facility
    self.number_of_facilities      = calc_number_of_facilities
    self.actual_duration           = calc_actual_duration
    self.were_results_reported     = calc_were_results_reported
    self.registered_in_calendar_year = calc_registered_in_calendar_year

    re=study.reported_events.where('subjects_affected is not null')
    if re.size > 0
      self.number_of_sae_subjects    = calc_number_of_subjects(re,'serious')
      self.number_of_nsae_subjects   = calc_number_of_subjects(re,'other')
    end

    min_stuff=calc_age('min')
    self.minimum_age_num           = min_stuff.first
    self.minimum_age_unit          = min_stuff.last

    max_stuff=calc_age('max')
    self.maximum_age_num           = max_stuff.first
    self.maximum_age_unit          = max_stuff.first

    self.months_to_report_results = calc_months_to_report_results
    tm=Time.now - stime
    self
  end

  def calc_has_us_facility
    return false if study.facilities.empty?
    !study.facilities.detect{|f|f.country=='United States'}.nil?
  end

  def calc_has_single_facility
    return false if study.facilities.empty?
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
    type == 'min' ?  study.eligibility.minimum_age : study.eligibility.maximum_age
  end

  def get_download_date
    dt=study.nlm_download_date_description.split('ClinicalTrials.gov processed this data on ').last
    dt.to_date if dt
  end

  def calc_number_of_subjects(reported_events,type)
    xtime=Time.now
    all=reported_events.select{|re| re.event_type == type}.map(&:subjects_affected)
    result=all.reduce(0, :+)
    tm=Time.now - xtime
    puts "time to load #{result}  #{type} subjects #{tm}    #{self.nct_id}" if tm > 1
    return result
  end

  def calc_registered_in_calendar_year
    study.first_received_date.year if study.first_received_date
  end

  def calc_number_of_facilities
    study.facilities.count
  end

  def calc_actual_duration
    return if !self.study.primary_completion_date or !self.study.start_date
    return if study.primary_completion_date_type != 'Actual'
    ((self.study.primary_completion_date.to_time -  self.study.start_date.to_time)/1.month.second).to_i
  end

  def calc_were_results_reported
    self.study.outcomes.size > 0
  end

  def calc_months_to_report_results
    return if !self.study.primary_completion_month_year or !study.first_received_results_date
    return if self.study.primary_completion_date_type != 'Actual'
    return if self.study.first_received_results_date.nil?
    ((self.study.first_received_results_date.to_time - self.study.primary_completion_date.to_time)/1.month.second).to_i
  end

end
