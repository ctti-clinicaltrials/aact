require 'csv'
require 'active_support/all'
class DataDefinition < AdminBase

  def self.populate(data=Util::FileManager.default_data_definitions)
    self.destroy_all
    self.populate_from_file(data)
    self.populate_row_counts
    self.populate_enumerations
  end

  def self.populate_from_file(data=Util::FileManager.default_data_definitions)
    header = data.first
    dataOut = []
    puts "about to populate data definitions table..."
    (2..data.last_row).each do |i|
      row = Hash[[header, data.row(i)].transpose]
      if !row['table'].nil? and !row['column'].nil?
        new(:db_section=>row['db section'].try(:downcase),
            :table_name=>row['table'].try(:downcase),
            :column_name=>row['column'].try(:downcase),
            :data_type=>row['data type'].try(:downcase),
            :source=>row['source'].try(:downcase),
            :ctti_note=>row['CTTI note'],
            :nlm_link=>row['nlm doc'],
           ).save!
      end
    end
  end

  def self.populate_row_counts
    # save count for each table where the primary key is id
    rows=where("column_name='id'")
    populate_from_file if rows.size==0
    rows.each{|row|
      begin
        results=ActiveRecord::Base.connection.execute("select count(*) from #{row.table_name}")
        row.row_count=results.getvalue(0,0) if results.ntuples == 1
        row.save
      rescue
        puts ">>>>  could not get row count for #{row.table_name}"
      end
    }
    # Studies table is an exception - primary key is nct_id
    row=where("table_name='studies' and column_name='nct_id'").first
    return if row.nil?
    results=ActiveRecord::Base.connection.execute("select count(*) from #{row.table_name}")
    row.row_count=results.getvalue(0,0) if results.ntuples == 1
    row.save
  end

  def self.populate_enumerations
    dd_rows=where("column_name='id'").size
    populate_from_file if dd_rows==0
    enums.each{|array|
      begin
        full_count=ActiveRecord::Base.connection.execute("SELECT count(*) FROM #{array.first}")
        rows=full_count.getvalue(0,0).to_i if full_count.ntuples == 1

        results=ActiveRecord::Base.connection.execute("
                    SELECT DISTINCT #{array.last}, COUNT(*) AS cnt
                      FROM #{array.first}
                     GROUP BY #{array.last}
                     ORDER BY cnt ASC")
        hash={}

        entries=results.ntuples - 1
        while entries >= 0 do
          val=results.getvalue(entries,0).to_s
          val='null' if val.size==0
          val='true' if val=='t'
          val='false' if val=='f'
          cnt=results.getvalue(entries,1)
          pct=(cnt.to_f/rows.to_f)*100
          display_count=cnt.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
          display_percent="#{pct.round(2)}%"
          hash[val]=[display_count,display_percent]
          entries=entries-1
        end
        row=where("table_name=? and column_name=?",array.first,array.last).first
        row.enumerations=hash.to_json
        row.save
      rescue e
        puts ">>>>  could not determine enumerations for #{array.first}  #{array.last}"
      end
    }
  end

  def self.enums
    [
      ['baseline_counts','units'],
      ['baseline_counts','scope'],
      ['baseline_measurements','category'],
      ['baseline_measurements','param_type'],
      ['calculated_values','has_single_facility'],
      ['calculated_values','has_us_facility'],
      ['calculated_values','registered_in_calendar_year'],
      ['calculated_values','were_results_reported'],
      ['central_contacts','contact_type'],
      ['design_groups','group_type'],
      ['design_outcomes','outcome_type'],
      ['designs','allocation'],
      ['designs','intervention_model'],
      ['designs','masking'],
      ['designs','observational_model'],
      ['designs','primary_purpose'],
      ['designs','caregiver_masked'],
      ['designs','investigator_masked'],
      ['designs','outcomes_assessor_masked'],
      ['designs','subject_masked'],
      ['drop_withdrawals','period'],
      ['eligibilities','gender'],
      ['eligibilities','gender_based'],
      ['eligibilities','healthy_volunteers'],
      ['eligibilities','sampling_method'],
      ['facilities','status'],
      ['facility_investigators','role'],
      ['facility_contacts','contact_type'],
      ['id_information','id_type'],
      ['interventions','intervention_type'],
      ['responsible_parties','responsible_party_type'],
      ['outcome_analyses','ci_n_sides'],
      ['outcome_analyses','dispersion_type'],
      ['outcome_analyses','non_inferiority_type'],
      ['outcome_counts','scope'],
      ['outcome_measurements','param_type'],
      ['reported_events','assessment'],
      ['reported_events','default_assessment'],
      ['reported_events','event_type'],
      ['result_agreements','pi_employee'],
      ['result_groups','result_type'],
      ['sponsors','agency_class'],
      ['sponsors','lead_or_collaborator'],
      ['studies','biospec_retention'],
      ['studies','completion_date_type'],
      ['studies','enrollment_type'],
      ['studies','expanded_access_type_individual'],
      ['studies','expanded_access_type_intermediate'],
      ['studies','expanded_access_type_treatment'],
      ['studies','has_expanded_access'],
      ['studies','has_dmc'],
      ['studies','is_fda_regulated_device'],
      ['studies','is_fda_regulated_drug'],
      ['studies','is_ppsd'],
      ['studies','is_unapproved_device'],
      ['studies','is_us_export'],
      ['studies','last_known_status'],
      ['studies','overall_status'],
      ['studies','phase'],
      ['studies','primary_completion_date_type'],
      ['studies','start_date_type'],
      ['studies','study_type'],
      ['study_references','reference_type'],
    ]
  end

end

