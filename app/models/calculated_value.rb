class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

class CalculatedValue < ActiveRecord::Base
  belongs_to :study, :foreign_key => 'nct_id'

  def self.refresh_table
    ActiveRecord::Base.connection.execute('REVOKE SELECT ON TABLE calculated_values FROM aact;')
    ActiveRecord::Base.connection.execute('TRUNCATE table calculated_values')
    ActiveRecord::Base.connection.execute("INSERT INTO calculated_values (
                 nct_id,
                 start_date,
                 verification_date,
                 completion_date,
                 primary_completion_date,
                 nlm_download_date
          )
          SELECT nct_id,
                 to_date(start_month_year, 'Month YYYY'),
                 to_date(verification_month_year, 'Month YYYY'),
                 to_date(completion_month_year, 'Month YYYY'),
                 to_date(primary_completion_month_year, 'Month YYYY'),
                 to_date(substring(nlm_download_date_description,43), 'Month DD,YYYY')
            FROM studies")

     ActiveRecord::Base.connection.execute("UPDATE calculated_values
           SET registered_in_calendar_year = x.res
          FROM (
              SELECT nct_id, date_part('year', start_date) as res
                FROM calculated_values c
               ) x
        WHERE x.nct_id = calculated_values.nct_id
          AND calculated_values.start_date IS NOT NULL")


    ActiveRecord::Base.connection.execute('UPDATE calculated_values SET were_results_reported=true WHERE nct_id in (SELECT distinct nct_id FROM outcomes)')


    ActiveRecord::Base.connection.execute("UPDATE calculated_values
           SET has_single_facility=true
         WHERE nct_id in
               (SELECT nct_id
                  FROM facilities
                 GROUP BY nct_id
                HAVING count(*)=1)")

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
           SET has_us_facility=true
         WHERE nct_id in
               (SELECT distinct nct_id
                  FROM facilities
                 WHERE country='United States')")

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
           SET number_of_facilities = x.res
          FROM (
              SELECT  nct_id, count(*) as res
                FROM facilities f
               GROUP BY nct_id
               ) x
        WHERE x.nct_id = calculated_values.nct_id
          AND number_of_facilities is null")

     ActiveRecord::Base.connection.execute("UPDATE calculated_values
           SET months_to_report_results = x.res
          FROM (
              SELECT  s.nct_id, (s.first_received_results_date - c.primary_completion_date)/30 as res
                FROM studies s, calculated_values c
               WHERE s.nct_id=c.nct_id
               ) x
        WHERE x.nct_id = calculated_values.nct_id")

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
           SET actual_duration = x.res
          FROM (
              SELECT  nct_id, (primary_completion_date -  start_date)/30 as res
                FROM calculated_values c
               ) x
        WHERE x.nct_id = calculated_values.nct_id")

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
           SET number_of_sae_subjects = x.res
          FROM (
               SELECT re.nct_id, sum(re.subjects_affected) as res
                 FROM reported_events re
                WHERE re.event_type='serious'
             GROUP BY re.nct_id) x
         WHERE x.nct_id = calculated_values.nct_id ")

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
           SET number_of_nsae_subjects = x.res
          FROM (
               SELECT re.nct_id, sum(re.subjects_affected) as res
                 FROM reported_events re
                WHERE re.event_type='other'
             GROUP BY re.nct_id) x
         WHERE x.nct_id = calculated_values.nct_id ")

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
         SET minimum_age_num = x.res
          FROM (
             SELECT nct_id, substring(minimum_age from 1 for position(' ' in minimum_age))::integer as res
               FROM eligibilities
              WHERE minimum_age != 'N/A'
                AND minimum_age != ''
              ) x
         WHERE x.nct_id = calculated_values.nct_id")

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
         SET maximum_age_num = x.res
          FROM (
             SELECT nct_id, substring(maximum_age from 1 for position(' ' in maximum_age))::integer as res
               FROM eligibilities
              WHERE maximum_age != 'N/A'
                AND maximum_age != ''
              ) x
         WHERE x.nct_id = calculated_values.nct_id")

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
         SET maximum_age_unit = x.res
          FROM (
             SELECT nct_id, substring(maximum_age from position(' ' in maximum_age)) as res
               FROM eligibilities
              WHERE maximum_age != 'N/A'
                AND maximum_age != ''
              ) x
         WHERE x.nct_id = calculated_values.nct_id")

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
         SET minimum_age_unit = x.res
          FROM (
             SELECT nct_id, substring(minimum_age from position(' ' in minimum_age)) as res
               FROM eligibilities
              WHERE minimum_age != 'N/A'
                AND minimum_age != ''
              ) x
         WHERE x.nct_id = calculated_values.nct_id")

    #  FIRST: Set sponsor_type using lead sponsor if there's one (Should only be one lead?)

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
         SET sponsor_type= x.agency_class
        FROM (
           SELECT distinct nct_id, agency_class
             FROM sponsors
            WHERE lead_or_collaborator='lead'
           GROUP BY nct_id, agency_class
           HAVING count(*)=1
           ) x
      WHERE x.nct_id = calculated_values.nct_id")

    #  SECOND: Set sponsor_type to NIH if no lead sponsor and one of the collaborators is NIH

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
         SET sponsor_type= 'NIH'
        FROM (
           SELECT distinct nct_id, agency_class
             FROM sponsors
            WHERE lead_or_collaborator='collaborator'
              AND agency_class='NIH'
           GROUP BY nct_id, agency_class
           ) x
      WHERE x.nct_id = calculated_values.nct_id
        AND calculated_values.sponsor_type IS NULL")

    #  THIRD: Set sponsor_type to Industry if no lead sponsor and no NIH collaborators

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
         SET sponsor_type= 'Industry'
        FROM (
           SELECT distinct nct_id, agency_class
             FROM sponsors
            WHERE lead_or_collaborator='collaborator'
              AND agency_class='Industry'
           GROUP BY nct_id, agency_class
           ) x
      WHERE x.nct_id = calculated_values.nct_id
        AND calculated_values.sponsor_type IS NULL")

    #  FOURTH: If not yet set, set sponsor_type to 'Other'

    ActiveRecord::Base.connection.execute("UPDATE calculated_values
         SET sponsor_type= 'Other'
        WHERE sponsor_type IS NULL")

    ActiveRecord::Base.connection.execute('GRANT SELECT ON TABLE calculated_values TO aact;')
  end

  def create_from(new_study)
    stime=Time.now
    self.study=new_study
    self.start_date                = study.start_month_year.try(:to_date)
    self.verification_date         = study.verification_month_year.try(:to_date)
    self.completion_date           = study.completion_month_year.try(:to_date)
    self.primary_completion_date   = study.primary_completion_month_year.try(:to_date)
    self.has_us_facility           = calc_has_us_facility
    self.has_single_facility       = calc_has_single_facility
    self.number_of_facilities      = calc_number_of_facilities
    self.actual_duration           = calc_actual_duration
    self.sponsor_type              = calc_sponsor_type
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
    ActiveRecord::Base.connection.execute('REVOKE SELECT ON TABLE calculated_values FROM aact;')
    !study.facilities.detect{|f|f.country=='United States'}.nil?
  end

  def calc_has_single_facility
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

  def calc_sponsor_type
    return nil if study.lead_sponsors.size > 1
    val=study.lead_sponsors.first.try(:agency_class)
    return val if val=='Industry' or val=='NIH'
    study.collaborators.each{|c|return 'NIH' if c.agency_class=='NIH'}
    study.collaborators.each{|c|return 'Industry' if c.agency_class=='Industry'}
    return 'Other'
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
    return if !self.primary_completion_date or !self.start_date
    return if study.primary_completion_date_type != 'Actual'
    ((self.primary_completion_date.to_time -  self.start_date.to_time)/1.month.second).to_i
  end

  def calc_were_results_reported
    self.study.outcomes.size > 0
  end

  def calc_months_to_report_results
    return if !self.study.primary_completion_month_year or !study.first_received_results_date
    return if self.study.primary_completion_date_type != 'Actual'
    return if self.study.first_received_results_date.nil?
    ((self.study.first_received_results_date.to_time - self.primary_completion_date.to_time)/1.month.second).to_i
  end

end
