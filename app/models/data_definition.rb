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
      puts row
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
    where("column_name='id'").each{|row|
      results=ActiveRecord::Base.connection.execute("select count(*) from #{row.table_name}")
      row.row_count=results.getvalue(0,0) if results.ntuples == 1
      row.save
    }
    # Studies table is an exception - primary key is nct_id
    row=where("table_name='studies' and column_name='nct_id'").first
    results=ActiveRecord::Base.connection.execute("select count(*) from #{row.table_name}")
    row.row_count=results.getvalue(0,0) if results.ntuples == 1
    row.save
  end

  def self.populate_enumerations
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
      ['studies','study_type'],
      ['studies','overall_status'],
      ['studies','last_known_status'],
      ['studies','phase'],
      ['studies','enrollment_type'],
      ['calculated_values','sponsor_type'],
      ['central_contacts','contact_type'],
      ['design_groups','group_type'],
      ['design_outcomes','outcome_type'],
      ['designs','observational_model'],
      ['designs','masking'],
      ['eligibilities','gender'],
      ['facility_contacts','contact_type'],
      ['id_information','id_type'],
      ['interventions','intervention_type'],
      ['responsible_parties','responsible_party_type'],
      ['sponsors','agency_class'],
      ['study_references','reference_type'],
      ['result_groups','result_type'],
      ['baseline_measurements','category'],
      ['baseline_measurements','param_type'],
      ['baseline_measurements','dispersion_type'],
      ['reported_events','event_type'],
    ]
  end

end

