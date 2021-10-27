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
    id_module_hash.merge!(status_module_hash)
                  .merge!(sponsor_collaborator_module)
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

  def id_module_hash
    id_module ='ProtocolSection|IdentificationModule'
    {
    # "#{id_module}|NCTId" => "studies#nct_id",
    # "#{id_module}|NCTIdAliasList|NCTIdAlias" => "id_information#id_value#where id_type='nct_alias'",
    # "#{id_module}|OrgStudyIdInfo|OrgStudyId" => "id_information#id_value#where id_type='org_study_id'",
    # "#{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryId" => "id_information#id_value#where id_type='secondary_id'",
    # "#{id_module}|Organization|OrgFullName" => "studies#source",
    # "#{id_module}|BriefTitle" => "studies#brief_title",
    # "#{id_module}|OfficialTitle" => "studies#official_title",
    # "#{id_module}|Acronym" => "studies#acronym",
    }
  end
  def status_module_hash
    status_module = 'ProtocolSection|StatusModule'
    {
    # "#{status_module}|StatusVerifiedDate" => "studies#verification_date",
    # "#{status_module}|OverallStatus" => "studies#overall_status",
    # "#{status_module}|LastKnownStatus" => "studies#last_known_status",
    # "#{status_module}|WhyStopped" => "studies#why_stopped",
    # "#{status_module}|ExpandedAccessInfo|HasExpandedAccess" => "studies#has_expanded_access",
    # "#{status_module}|StartDateStruct|StartDate" => "studies#start_date",
    # "#{status_module}|StartDateStruct|StartDateType" => "studies#start_date_type",
    # "#{status_module}|PrimaryCompletionDateStruct|PrimaryCompletionDate" => "studies#primary_completion_date",
    # "#{status_module}|PrimaryCompletionDateStruct|PrimaryCompletionDateType" => "studies#primary_completion_date_type",
    # "#{status_module}|CompletionDateStruct|CompletionDate" => "studies#completion_date",
    # "#{status_module}|CompletionDateStruct|CompletionDateType" => "studies#completion_date_type",
    # "#{status_module}|StudyFirstSubmitDate" => "studies#study_first_submitted_date",
    # "#{status_module}|StudyFirstSubmitQCDate" => "studies#study_first_submitted_qc_date",
    # "#{status_module}|StudyFirstPostDateStruct|StudyFirstPostDate" => "studies#study_first_posted_date",
    # "#{status_module}|StudyFirstPostDateStruct|StudyFirstPostDateType" => "studies#study_first_posted_date_type",
    # "#{status_module}|ResultsFirstSubmitDate" => "studies#results_first_submitted_date",
    # "#{status_module}|ResultsFirstSubmitQCDate" => "studies#results_first_submitted_qc_date",
    # "#{status_module}|ResultsFirstPostDateStruct|ResultsFirstPostDate" => "studies#results_first_posted_date",
    # "#{status_module}|ResultsFirstPostDateStruct|ResultsFirstPostDateType" => "studies#results_first_posted_date_type",
    # "#{status_module}|DispFirstSubmitDate" => "studies#disposition_first_submitted_date",
    # "#{status_module}|DispFirstSubmitQCDate" => "studies#disposition_first_submitted_qc_date",
    # "#{status_module}|DispFirstPostDateStruct|DispFirstPostDate" => "studies#disposition_first_posted_date",
    # "#{status_module}|DispFirstPostDateStruct|DispFirstPostDateType" => "studies#disposition_first_posted_date_type",
    # "#{status_module}|LastUpdateSubmitDate" => "studies#last_update_submitted_qc_date",
    # "#{status_module}|LastUpdatePostDateStruct|LastUpdatePostDate" => "studies#last_update_posted_date",
    # "#{status_module}|LastUpdatePostDateStruct|LastUpdatePostDateType" => "studies#last_update_posted_date_type",
    }
  end

  def sponsor_collaborator_module
    sc_module = 'ProtocolSection|SponsorCollaboratorsModule'
    {
      # "#{sc_module}|ResponsibleParty|ResponsiblePartyType" => "responsible_parties#responsible_party_type",
      # "#{sc_module}|ResponsibleParty|ResponsiblePartyInvestigatorFullName" => "responsible_parties#name",
      # "#{sc_module}|ResponsibleParty|ResponsiblePartyInvestigatorTitle" => "responsible_parties#title",
      # "#{sc_module}|ResponsibleParty|ResponsiblePartyInvestigatorAffiliation" => "responsible_parties#affiliation",
      # "#{sc_module}|ResponsibleParty|ResponsiblePartyOldOrganization" => "responsible_parties#organization",
      # "#{sc_module}|LeadSponsor|LeadSponsorName" => "sponsors#name#where lead_or_collaborator='lead'",
      # "#{sc_module}|LeadSponsor|LeadSponsorClass" => "sponsors#agency_class#where lead_or_collaborator='lead'",
      # "#{sc_module}|CollaboratorList|Collaborator|CollaboratorName" => "sponsors#name#where lead_or_collaborator='collaborator'",
      # "#{sc_module}|CollaboratorList|Collaborator|CollaboratorClass" => "sponsors#agency_class#where lead_or_collaborator='collaborator'",
    }
  end
  

  
  # selectors that aren't in the database
  # #{id_module}|OrgStudyIdInfo|OrgStudyIdType
  # #{id_module}|OrgStudyIdInfo|OrgStudyIdDomain
  # #{id_module}|OrgStudyIdInfo|OrgStudyIdLink
  # #{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdType
  # #{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdDomain
  # #{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdLink
  # #{id_module}|Organization|OrgClass
  # #{status_module}|DelayedPosting
  # #{status_module}|ExpandedAccessInfo|ExpandedAccessNCTId
  # #{status_module}|ExpandedAccessInfo|ExpandedAccessStatusForNCTId
  # #{status_module}|ResultsFirstPostedQCCommentsDateStruct|ResultsFirstPostedQCCommentsDate
  # #{status_module}|ResultsFirstPostedQCCommentsDateStruct|ResultsFirstPostedQCCommentsDateType
  # #{sc_module}|ResponsibleParty|ResponsiblePartyOldNameTitle
  
end
