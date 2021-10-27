class Verifier < ActiveRecord::Base

  def self.refresh(params={schema: 'ctgov'})
    Verifier.destroy_all
    Verifier.new.verify(params)
  end

  def set_schema(schema)
    # expects the schema to be either ctgov or ctgov_beta
    con = ActiveRecord::Base.connection
    username = ENV['AACT_DB_SUPER_USERNAME'] || 'ctti'
    db_name = ENV['AACT_BACK_DATABASE_NAME'] || 'aact'
    con.execute("ALTER ROLE #{username} IN DATABASE #{db_name} SET SEARCH_PATH TO #{schema}, support, public;")
    
    ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.logger = nil
  end
  
  def verify(params={schema: 'ctgov'})
    set_schema(params[:schema])
    study_statistics = ClinicalTrialsApi.study_statistics.dig('StudyStatistics', "ElmtDefs", "Study")
    return unless study_statistics

    differences = []
    # I first add the count so that we can know if the differences might be caused by having a different amount of studies
    source_study_counts = study_statistics.dig('nInstances')
    db_study_counts = Study.count
    differences<< {source_study_count: source_study_counts, db_study_count:  db_study_counts} unless same?(source_study_counts,  db_study_counts)
    
    # Now I add the differences for each selector
    all_locations.each do |key,value|
      found = diff_hash(study_statistics, key, value)
      differences << found unless found.blank?
    end

    last_run = Time.now
    self.save

    return differences
  end

  def same?(int1,int2)
    int1.to_i == int2.to_i
    
  end

  def diff_hash(hash, selector, location)
    selector.split('|').each do |selector_part|
      hash = hash.dig(selector_part)
    end
    section = selector.last 

    return unless hash

    all_instances = hash.dig("nInstances")
    uniq_instances = hash.dig("nUniqueValues")
    
    all_counts, uniq_counts = get_counts(location)

      unless same?(all_counts, all_instances) && same?(uniq_counts, uniq_instances)
        return {
                    source: selector,
                    destination: location,
                    source_instances: all_instances,
                    destination_instances: all_counts,
                    source_unique_values: uniq_instances,
                    destination_unique_values: uniq_counts,
              }
      else 
        return false
      end
  end

  def all_locations
    {
      # "#{id_module}|NCTId" => "studies#nct_id",
      # "#{id_module}|NCTIdAliasList|NCTIdAlias" => "id_information#id_value#where id_type='nct_alias'",
      # "#{id_module}|OrgStudyIdInfo|OrgStudyId" => "id_information#id_value#where id_type='org_study_id'",
      # "#{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryId" => "id_information#id_value#where id_type='secondary_id'",
      # "#{id_module}|Organization|OrgFullName" => "studies#source",
      # "#{id_module}|BriefTitle" => "studies#brief_title",
      # "#{id_module}|OfficialTitle" => "studies#official_title",
      # "#{id_module}|Acronym" => "studies#acronym",
      "#{status_module}|StatusVerifiedDate" => "studies#verification_date",
      "#{status_module}|OverallStatus" => "studies#overall_status",
      "#{status_module}|LastKnownStatus" => "studies#last_known_status",
      "#{status_module}|WhyStopped" => "studies#why_stopped",
      "#{status_module}|ExpandedAccessInfo|HasExpandedAccess" => "studies#has_expanded_access",

    }
  end

  def get_counts(location)
    return unless location && location.kind_of?(String)

   
    # location example "studies#nct_id"
    array = location.split('#')
    additional_info = ''
    additional_info = array[2] if array.length > 2

    con = ActiveRecord::Base.connection
    
    all_counts = con.execute("select count(#{array[1]}) from #{array[0]} #{additional_info}")
    all_counts = all_counts.getvalue(0,0) if all_counts.ntuples == 1

    uniq_counts = con.execute("select count(distinct #{array[1]}) from #{array[0]} #{additional_info}")
    uniq_counts = uniq_counts.getvalue(0,0) if uniq_counts.ntuples == 1
    
    return all_counts, uniq_counts
  end

  def id_module
    'ProtocolSection|IdentificationModule'
  end
  def status_module
    'ProtocolSection|StatusModule'
  end

  
  # aren't saving
  # ProtocolSection|IdentificationModule|OrgStudyIdInfo|OrgStudyIdType
  # ProtocolSection|IdentificationModule|OrgStudyIdInfo|OrgStudyIdDomain
  # ProtocolSection|IdentificationModule|OrgStudyIdInfo|OrgStudyIdLink
  # ProtocolSection|IdentificationModule|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdType
  # ProtocolSection|IdentificationModule|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdDomain
  # ProtocolSection|IdentificationModule|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdLink
  # ProtocolSection|IdentificationModule|Organization|OrgClass
  # ProtocolSection|StatusModule|DelayedPosting
end
