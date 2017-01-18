require 'csv'
require 'active_support/all'
class DataDefinition < ActiveRecord::Base

  def self.populate_from_file
    data = Roo::Spreadsheet.open(ClinicalTrials::FileManager.data_dictionary)
    header = data.first
    dataOut = []
    puts "about to populate data definitions table..."
    (2..data.last_row).each do |i|
      row = Hash[[header, data.row(i)].transpose]
      if !row['table'].nil? and !row['column'].nil?
        new(:db_section=>row['db section'].downcase,
            :table_name=>row['table'].downcase,
            :column_name=>row['column'].downcase,
            :data_type=>row['data type'].downcase,
            :source=>row['source'].downcase,
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
      results=ActiveRecord::Base.connection.execute("select count(*) from #{row.table_name}")
      row.row_count=results.getvalue(0,0) if results.ntuples == 1
      row.save
    }
    # Studies table is an exception - primary key is nct_id
    row=where("table_name='studies' and column_name='nct_id'").first
    return if row.nil?
    results=ActiveRecord::Base.connection.execute("select count(*) from #{row.table_name}")
    row.row_count=results.getvalue(0,0) if results.ntuples == 1
    row.save
  end

  def self.populate_enumerations
    rows=where("column_name='id'")
    populate_from_file if rows.size==0
    enums.each{|array|
      results=ActiveRecord::Base.connection.execute("
                    SELECT DISTINCT #{array.last}, COUNT(*) AS cnt
                      FROM #{array.first}
                     GROUP BY #{array.last}
                     ORDER BY cnt ASC")
      hash={}
      cntr=results.ntuples - 1
      while cntr >= 0 do
        val=results.getvalue(cntr,0).to_s
        val='-null-' if val.size==0
        val_count=results.getvalue(cntr,1).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
        hash[val]=val_count
        cntr=cntr-1
      end
      row=where("table_name=? and column_name=?",array.first,array.last).first
      row.enumerations=hash.to_json
      row.save
    }
  end

  def self.enums
    [
      ['baseline_measurements','category'],
      ['baseline_measurements','param_type'],
      ['calculated_values','sponsor_type'],
      ['central_contacts','contact_type'],
      ['design_groups','group_type'],
      ['design_outcomes','outcome_type'],
      ['designs','observational_model'],
      ['designs','masking'],
      ['eligibilities','gender'],
      ['eligibilities','gender_based'],
      ['eligibilities','sampling_method'],
      ['facilities','status'],
      ['facility_investigators','role'],
      ['facility_contacts','contact_type'],
      ['id_information','id_type'],
      ['interventions','intervention_type'],
      ['responsible_parties','responsible_party_type'],
      ['outcome_analyses','ci_n_sides'],
      ['outcome_analyses','non_inferiority_type'],
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
      ['studies','start_date_type'],
      ['studies','study_type'],
      ['study_references','reference_type'],
    ]
  end

end

