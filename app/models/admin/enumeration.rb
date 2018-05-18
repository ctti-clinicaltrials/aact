require 'active_support/all'
module Admin
  class Enumeration < Admin::AdminBase

    def self.populate
      new.populate
    end

    def populate
      con=ActiveRecord::Base.connection
      enums.each{|array|
        begin
          table_name=array.first
          column_name=array.last
          full_count=con.execute("SELECT count(*) FROM #{table_name}")
          rows=full_count.getvalue(0,0).to_i if full_count.ntuples == 1

          results=con.execute("
                      SELECT DISTINCT #{column_name}, COUNT(*) AS cnt
                        FROM #{table_name}
                       GROUP BY #{column_name}
                       ORDER BY cnt ASC")

          entries=results.ntuples - 1
          # hash to be used to populate the enumeration column of the associated data definition record
          hash={}
          # healthcheck hash to be used to create a health check record for the enumeration
          hc_hash={:table_name=>table_name,:column_name=>column_name}
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
            hc_hash[:column_value]=val
            hc_hash[:value_count]=cnt.to_i
            hc_hash[:value_percent]=pct
            create_from(hc_hash) if hc_hash.size > 2
            entries=entries-1
          end
          row=Admin::DataDefinition.where("table_name=? and column_name=?",table_name,column_name).first
          if row
            row.enumerations=hash.to_json
            row.save
          end
        rescue => e
          puts ">>>>  could not determine enumerations for #{table_name}  #{column_name}"
          puts e.inspect
        end
      }
    end

    def create_from(hash)
      # Bi-Monthly creation of Enumeration rows.
      Admin::Enumeration.new(
        {:table_name     => hash[:table_name],
         :column_name    => hash[:column_name],
         :column_value   => hash[:column_value],
         :value_count    => hash[:value_count],
         :value_percent  => hash[:value_percent],
        }
      ).save! if is_day_to_create_enums?
    end

    def is_day_to_create_enums?
      # We create set of Enumerations on the 2nd & 16th day of the month.
      [2,16].include? Time.zone.today.day
      # We avoid the 1st of the month cuz full loads run that day & might at some point take more than 24 hrs.
    end

    def self.get_values_for(table_name, column_name)
      col_values=Admin::Enumeration.where("table_name=? and column_name=?", table_name, column_name)
        .select("column_value")
        .group_by &:column_value
    end

    def self.get_last_two_for(table_name, column_name, val)
      rows=where("table_name=? and column_name=? and column_value=?", table_name, column_name, val).order("created_at")
      if rows.size > 1
        return {:last=>rows.last, :next_last=>rows.offset(1).last} if rows.size > 1
      else
        return {}
      end
    end

    def enums
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
        ['documents','document_type'],
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
        ['pending_results','event'],
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
end
