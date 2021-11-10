class Verifier < ActiveRecord::Base
  APIJSON =  ClinicalTrialsApi.study_statistics

  def write_data_to_file(schema='ctgov')
    folder = Util::FileManager.new.study_statistics_directory
    # save the data from the study statistics endpoint for reference
    File.write("#{folder}/verifier_source_#{schema}.json".remove('\''), JSON.dump(self.source))
    # save json with differences
    diff_file = "#{folder}/verifier_differences_#{schema}".remove('\'')
    File.write("#{diff_file}.json", JSON.dump(self.differences))
    
    # save csv with differences
    headers = %w[
                source
                destination
                source_instances
                destination_instances
                source_unique_values
                destination_unique_values
              ]

    CSV.open("#{diff_file}.csv", 'w', write_headers: true, headers: headers) do |row|
      self.differences.each do |hash|
        row << [
                hash["source"],
                hash["destination"],
                hash["source_instances"],
                hash["destination_instances"],
                hash["source_unique_values"],
                hash["destination_unique_values"],
              ]
      end
    end
  end

  def get_source_from_file(file_path="#{Util::FileManager.new.study_statistics_directory}/verifier_source_ctgov.json")
    file = File.read(file_path)
    self.update(source: JSON.parse(file))
  end

  def self.return_correct_schema(name = 'ctgov')
    return 'ctgov_beta' if name =~ /beta/
       
    'ctgov'
  end

  def self.refresh(params={schema: 'ctgov'})
    # this is a safety messure to make sure the correct schema name is used
    schema = self.return_correct_schema(params[:schema])
    begin
      verifier = Verifier.create(source: APIJSON.dig('StudyStatistics', "ElmtDefs", "Study"))
      verifier.verify(schema)
      verifier.write_data_to_file(schema)
    rescue => error
      msg="#{error.message} (#{error.class} #{error.backtrace}"
      ErrorLog.error(msg)
      Airbrake.notify(error)
    end
  end

  # BETA MIGRATION
  def set_schema(schema)
    # this is a safety messure to make sure the correct schema name is used
    schema = Verifier.return_correct_schema(schema)
    # expects the schema to be either ctgov or ctgov_beta
    con = ActiveRecord::Base.connection
    username = ENV['AACT_DB_SUPER_USERNAME'] || 'ctti'
    db_name = ENV['AACT_BACK_DATABASE_NAME'] || 'aact'
    con.execute("ALTER ROLE #{username} IN DATABASE #{db_name} SET SEARCH_PATH TO #{schema}, support, public;")
    
    ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.logger = nil
  end

  def verify(schema ='ctgov')
    # this is a safety messure to make sure the correct schema name is used
    schema = Verifier.return_correct_schema(schema)
    set_schema(schema)
    
    return if self.source.blank?

    diff = []
    # I first add the count so that we can know if the differences might be caused by having a different amount of studies
    source_study_counts = self.source.dig('nInstances')
    db_study_counts = Study.count
    diff<< {source_study_count: source_study_counts, db_study_count:  db_study_counts} unless same?(source_study_counts,  db_study_counts)
    
    # Now I add the differences for each selector
    places = all_locations
    total = places.count
    places.each do |key,value|
      begin
        puts "countdown: #{total} --#{key}_________"
        found = diff_hash(key, value)
        diff << found unless found.blank?
        total -= 1
      rescue => error
        msg="#{error.message} (#{error.class} #{error.backtrace}"
        ErrorLog.error(msg)
        Airbrake.notify(error)
        next
      end
    end

    self.last_run = Time.now
    self.differences = diff

    self.save

    return diff
  end

  def same?(int1,int2)
    int1.to_i == int2.to_i
    
  end

  def diff_hash(selector, location)
    hash = self.source
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
                  .merge!(sponsor_collaborator_module_hash)
                  .merge!(oversight_module_hash)
                  .merge!(description_module_hash)
                  .merge!(conditions_module_hash)
                  .merge!(design_module_hash)
                  .merge!(arms_interventions_module_hash)
                  .merge!(outcomes_module_hash) 
                  .merge!(eligibility_module_hash)
                  .merge!(contacts_location_module_hash)
                  .merge!(references_module_hash)
                  .merge!(ipd_sharing_module_hash)
                  .merge!(participant_flow_module_hash)
                  .merge!(baseline_characteristics_module_hash)
                  .merge!(outcome_measures_module_hash)
                  .merge!(adverse_events_module_hash)
                  .merge!(more_info_module_hash)
                  .merge!(annotation_module_hash)
                  .merge!(large_document_module_hash)
                  .merge!(misc_info_module_hash)
                  .merge!(condition_browse_module_hash)
                  .merge!(intervention_browse_module_hash)   
  end

  def get_counts(location)
    return unless location && location.kind_of?(String)

    # location example "studies#nct_id#where nct_id is not null and nct_id <> ''"
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

  # Protcol section___________________________________________________________

  def id_module_hash
    id_module ='ProtocolSection|IdentificationModule'
    {
    "#{id_module}|NCTId"                                           => 'studies#nct_id',
    "#{id_module}|NCTIdAliasList|NCTIdAlias"                       => "id_information#id_value#where id_type='nct_alias' and id_value is not null and id_value <> ''",
    "#{id_module}|OrgStudyIdInfo|OrgStudyId"                       => "id_information#id_value#where id_type='org_study_id' and id_value is not null and id_value <> ''",
    "#{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryId" => "id_information#id_value#where id_type='secondary_id' and id_value is not null and id_value <> ''",
    "#{id_module}|Organization|OrgFullName"                        => "studies#source#where source is not null and source <> ''",
    "#{id_module}|BriefTitle"                                      => "studies#brief_title#where brief_title is not null and brief_title <> ''",
    "#{id_module}|OfficialTitle"                                   => "studies#official_title#where official_title is not null and official_title <> ''",
    "#{id_module}|Acronym"                                         => "studies#acronym#where acronym is not null and acronym <> ''",
    }
  end

  def status_module_hash
    status_module = 'ProtocolSection|StatusModule'
    {
    "#{status_module}|StatusVerifiedDate"                                    => 'studies#verification_date#where verification_date is not null',
    "#{status_module}|OverallStatus"                                         => "studies#overall_status#where overall_status is not null and overall_status <> ''",
    "#{status_module}|LastKnownStatus"                                       => "studies#last_known_status#where last_known_status is not null and last_known_status <> ''",
    "#{status_module}|WhyStopped"                                            => "studies#why_stopped#where why_stopped is not null and why_stopped <> ''",
    "#{status_module}|ExpandedAccessInfo|HasExpandedAccess"                  => 'studies#has_expanded_access#where has_expanded_access is not null',
    
    "#{status_module}|StartDateStruct|StartDate"                             => 'studies#start_date#where start_date is not null',
    "#{status_module}|StartDateStruct|StartDateType"                         => "studies#start_date_type#where start_date_type is not null and start_date_type <> ''",
    
    "#{status_module}|PrimaryCompletionDateStruct|PrimaryCompletionDate"     => 'studies#primary_completion_date#where primary_completion_date is not null',
    "#{status_module}|PrimaryCompletionDateStruct|PrimaryCompletionDateType" => "studies#primary_completion_date_type#where primary_completion_date_type is not null and primary_completion_date_type <> ''",
    
    "#{status_module}|CompletionDateStruct|CompletionDate"                   => 'studies#completion_date#where completion_date is not null',
    "#{status_module}|CompletionDateStruct|CompletionDateType"               => "studies#completion_date_type#where completion_date_type is not null and completion_date_type <> ''",
    
    "#{status_module}|StudyFirstSubmitDate"                                  => 'studies#study_first_submitted_date#where study_first_submitted_date is not null',
    "#{status_module}|StudyFirstSubmitQCDate"                                => 'studies#study_first_submitted_qc_date#where study_first_submitted_qc_date is not null',
    
    "#{status_module}|StudyFirstPostDateStruct|StudyFirstPostDate"           => 'studies#study_first_posted_date#where study_first_posted_date is not null',
    "#{status_module}|StudyFirstPostDateStruct|StudyFirstPostDateType"       => "studies#study_first_posted_date_type#where study_first_posted_date_type is not null and study_first_posted_date_type <> ''",
    
    "#{status_module}|ResultsFirstSubmitDate"                                => 'studies#results_first_submitted_date#where results_first_submitted_date is not null',
    "#{status_module}|ResultsFirstSubmitQCDate"                              => 'studies#results_first_submitted_qc_date#where results_first_submitted_qc_date is not null',
    
    "#{status_module}|ResultsFirstPostDateStruct|ResultsFirstPostDate"       => 'studies#results_first_posted_date#where results_first_posted_date is not null',
    "#{status_module}|ResultsFirstPostDateStruct|ResultsFirstPostDateType"   => "studies#results_first_posted_date_type#where results_first_posted_date_type is not null and results_first_posted_date_type <> ''",
    
    "#{status_module}|DispFirstSubmitDate"                                   => 'studies#disposition_first_submitted_date#where disposition_first_submitted_date is not null',
    "#{status_module}|DispFirstSubmitQCDate"                                 => 'studies#disposition_first_submitted_qc_date#where disposition_first_submitted_qc_date is not null',
    
    "#{status_module}|DispFirstPostDateStruct|DispFirstPostDate"             => 'studies#disposition_first_posted_date#where disposition_first_submitted_date is not null',
    "#{status_module}|DispFirstPostDateStruct|DispFirstPostDateType"         => "studies#disposition_first_posted_date_type#where disposition_first_posted_date_type is not null and disposition_first_posted_date_type <> ''",
    
    "#{status_module}|LastUpdateSubmitDate"                                  => 'studies#last_update_submitted_qc_date#where last_update_submitted_qc_date is not null',
    "#{status_module}|LastUpdatePostDateStruct|LastUpdatePostDate"           => 'studies#last_update_posted_date#where last_update_posted_date is not null',
    "#{status_module}|LastUpdatePostDateStruct|LastUpdatePostDateType"       => "studies#last_update_posted_date_type#where last_update_posted_date_type is not null and last_update_posted_date_type <> ''",
    }
  end

  def sponsor_collaborator_module_hash
    sc_module = 'ProtocolSection|SponsorCollaboratorsModule'
    {
      "#{sc_module}|ResponsibleParty|ResponsiblePartyType"                    => "responsible_parties#responsible_party_type#where responsible_party_type is not null and responsible_party_type <> ''",
      "#{sc_module}|ResponsibleParty|ResponsiblePartyInvestigatorFullName"    => "responsible_parties#name#where name is not null and name <> ''",
      "#{sc_module}|ResponsibleParty|ResponsiblePartyInvestigatorTitle"       => "responsible_parties#title#where title is not null and title <> ''",
      "#{sc_module}|ResponsibleParty|ResponsiblePartyInvestigatorAffiliation" => "responsible_parties#affiliation#where affiliation is not null and affiliation <> ''",
      "#{sc_module}|ResponsibleParty|ResponsiblePartyOldOrganization"         => "responsible_parties#organization#where organization is not null and organization <> ''",
      
      "#{sc_module}|LeadSponsor|LeadSponsorName"                              => "sponsors#name#where lead_or_collaborator='lead' and name is not null and name <> ''",
      "#{sc_module}|LeadSponsor|LeadSponsorClass"                             => "sponsors#agency_class#where lead_or_collaborator='lead' and agency_class is not null and agency_class <> ''",
      
      "#{sc_module}|CollaboratorList|Collaborator|CollaboratorName"           => "sponsors#name#where lead_or_collaborator='collaborator' and name is not null and name <> ''",
      "#{sc_module}|CollaboratorList|Collaborator|CollaboratorClass"          => "sponsors#agency_class#where lead_or_collaborator='collaborator' and agency_class is not null and agency_class <> ''",
    }
  end

  def oversight_module_hash
    over_module = 'ProtocolSection|OversightModule'
    {
      "#{over_module}|OversightHasDMC"      => 'studies#has_dmc#where has_dmc is not null',
      "#{over_module}|IsFDARegulatedDrug"   => 'studies#is_fda_regulated_drug#where is_fda_regulated_drug is not null',
      "#{over_module}|IsFDARegulatedDevice" => 'studies#is_fda_regulated_device#where is_fda_regulated_device is not null',
      "#{over_module}|IsUnapprovedDevice"   => 'studies#is_unapproved_device#where is_unapproved_device is not null',
      "#{over_module}|IsPPSD"               => 'studies#is_ppsd#where is_ppsd is not null',
      "#{over_module}|IsUSExport"           => 'studies#is_us_export#where is_us_export is not null',
    }
  end

  def description_module_hash
    description_module = 'ProtocolSection|DescriptionModule'
    {
      "#{description_module}|BriefSummary"        => "brief_summaries#description#where description is not null and description <>''",
      "#{description_module}|DetailedDescription" => "detailed_descriptions#description#where description is not null and description <>''",
    }
  end

  def conditions_module_hash
    conditions_module = 'ProtocolSection|ConditionsModule'
    {
      "#{conditions_module}|ConditionList|Condition" => "conditions#name#where name is not null and name <>''",
      "#{conditions_module}|KeywordList|Keyword"     => "keywords#name#where name is not null and name <>''",
    }
  end

  def design_module_hash
    design_module = 'ProtocolSection|DesignModule'
    {
      "#{design_module}|StudyType" => "studies#study_type#where study_type is not null and study_type <>''",
      
      "#{design_module}|ExpandedAccessTypes|ExpAccTypeIndividual"   => 'studies#expanded_access_type_individual#where expanded_access_type_individual is not null',
      "#{design_module}|ExpandedAccessTypes|ExpAccTypeIntermediate" => 'studies#expanded_access_type_intermediate#where expanded_access_type_intermediate is not null',
      "#{design_module}|ExpandedAccessTypes|ExpAccTypeTreatment"    => 'studies#expanded_access_type_treatment#where expanded_access_type_treatment is not null',
      
      "#{design_module}|PatientRegistry" => "studies#study_type#where study_type iLIKE '%Patient Registry%' or study_type iLIKE '%PatientRegistry%'",
      "#{design_module}|TargetDuration"  => "studies#target_duration#where target_duration is not null and target_duration <>''",
      "#{design_module}|PhaseList|Phase" => "studies#phase#where phase is not null and phase <>''",
      
      "#{design_module}|DesignInfo|DesignAllocation"                                      => "designs#allocation#where allocation is not null and allocation <>''",
      "#{design_module}|DesignInfo|DesignInterventionModel"                               => "designs#intervention_model#where intervention_model is not null and intervention_model <>''",
      "#{design_module}|DesignInfo|DesignInterventionModelDescription"                    => "designs#intervention_model_description#where intervention_model_description is not null and intervention_model_description <>''",
      "#{design_module}|DesignInfo|DesignPrimaryPurpose"                                  => "designs#primary_purpose#where primary_purpose is not null and primary_purpose <>''",
      "#{design_module}|DesignInfo|DesignObservationalModelList|DesignObservationalModel" => "designs#observational_model#where observational_model is not null and observational_model <>''",
      "#{design_module}|DesignInfo|DesignTimePerspectiveList|DesignTimePerspective"       => "designs#time_perspective#where time_perspective is not null and time_perspective <>''",
      "#{design_module}|DesignInfo|DesignMaskingInfo|DesignMasking"                       => "designs#masking#where masking is not null and masking <>''",
      "#{design_module}|DesignInfo|DesignMaskingInfo|DesignMaskingDescription"            => "designs#masking_description#where masking_description is not null and masking_description <>''",
      "#{design_module}|DesignInfo|DesignMaskingInfo|DesignWhoMaskedList|DesignWhoMasked" => 'designs#CONCAT(subject_masked,caregiver_masked,investigator_masked,outcomes_assessor_masked)# where COALESCE(subject_masked,caregiver_masked,investigator_masked,outcomes_assessor_masked) is not null',
      
      "#{design_module}|BioSpec|BioSpecRetention"   => "studies#biospec_retention#where biospec_retention is not null and biospec_retention <>''",
      "#{design_module}|BioSpec|BioSpecDescription" => "studies#biospec_description#where biospec_description is not null and biospec_description <>''",
      
      "#{design_module}|EnrollmentInfo|EnrollmentCount" => 'studies#enrollment#where enrollment is not null',
      "#{design_module}|EnrollmentInfo|EnrollmentType"  => "studies#enrollment_type#where enrollment_type is not null and enrollment_type <>''",
    }
  end

  def arms_interventions_module_hash
    ai_module = 'ProtocolSection|ArmsInterventionsModule'
    {
      "#{ai_module}|ArmGroupList|ArmGroup|ArmGroupLabel"       => "design_groups#title#where title is not null and title <>''",
      "#{ai_module}|ArmGroupList|ArmGroup|ArmGroupType"        => "design_groups#group_type#where group_type is not null and group_type <>''",
      "#{ai_module}|ArmGroupList|ArmGroup|ArmGroupDescription" => "design_groups#description#where description is not null and description <>''",
      
      "#{ai_module}|InterventionList|Intervention|InterventionType"                                        => "interventions#intervention_type#where intervention_type is not null and intervention_type <>''",
      "#{ai_module}|InterventionList|Intervention|InterventionName"                                        => "interventions#name#where name is not null and name <>''",
      "#{ai_module}|InterventionList|Intervention|InterventionDescription"                                 => "interventions#description#where description is not null and description <>''",
      "#{ai_module}|InterventionList|Intervention|InterventionArmGroupLabelList|InterventionArmGroupLabel" => "design_groups#title#where title is not null and title <>''",
      "#{ai_module}|InterventionList|Intervention|InterventionOtherNameList|InterventionOtherName"         => "intervention_other_names#name#where name is not null and name <>''",
    } 
  end

  def outcomes_module_hash
    outcome_module = 'ProtocolSection|OutcomesModule'
    {
      "#{outcome_module}|PrimaryOutcomeList|PrimaryOutcome|PrimaryOutcomeMeasure"           => "design_outcomes#measure#where outcome_type iLike 'Primary' and measure is not null and measure <>''",
      "#{outcome_module}|PrimaryOutcomeList|PrimaryOutcome|PrimaryOutcomeDescription"       => "design_outcomes#description#where outcome_type iLike 'Primary' and description is not null and description <>''",
      "#{outcome_module}|PrimaryOutcomeList|PrimaryOutcome|PrimaryOutcomeTimeFrame"         => "design_outcomes#time_frame#where outcome_type iLike 'Primary' and time_frame is not null and time_frame <>''",

      "#{outcome_module}|SecondaryOutcomeList|SecondaryOutcome|SecondaryOutcomeMeasure"     => "design_outcomes#measure#where outcome_type iLike 'Secondary' and measure is not null and measure <>''",
      "#{outcome_module}|SecondaryOutcomeList|SecondaryOutcome|SecondaryOutcomeDescription" => "design_outcomes#description#where outcome_type iLike 'Secondary' and description is not null and description <>''",
      "#{outcome_module}|SecondaryOutcomeList|SecondaryOutcome|SecondaryOutcomeTimeFrame"   => "design_outcomes#time_frame#where outcome_type iLike 'Secondary' and time_frame is not null and time_frame <>''",

      "#{outcome_module}|OtherOutcomeList|OtherOutcome|OtherOutcomeMeasure"                 => "design_outcomes#measure#where outcome_type iLike 'Other' and measure is not null and measure <>''",
      "#{outcome_module}|OtherOutcomeList|OtherOutcome|OtherOutcomeDescription"             => "design_outcomes#description#where outcome_type iLike 'Other' and description is not null and description <>''",
      "#{outcome_module}|OtherOutcomeList|OtherOutcome|OtherOutcomeTimeFrame"               => "design_outcomes#time_frame#where outcome_type iLike 'Other' and time_frame is not null and time_frame <>''",
    }
  end

  def eligibility_module_hash
    e_module = 'ProtocolSection|EligibilityModule'
    {
      "#{e_module}|EligibilityCriteria" => "eligibilities#criteria#where criteria is not null and criteria <> ''",
      "#{e_module}|HealthyVolunteers"   => "eligibilities#healthy_volunteers#where healthy_volunteers is not null and healthy_volunteers <> ''",
      "#{e_module}|Gender"              => "eligibilities#gender#where gender is not null and gender <> ''",
      "#{e_module}|GenderBased"         => 'eligibilities#gender_based#where gender_based is not null',
      "#{e_module}|GenderDescription"   => "eligibilities#gender_description#where gender_description is not null and gender_description <> ''",
      "#{e_module}|MinimumAge"          => "eligibilities#minimum_age#where minimum_age is not null and minimum_age <> ''",
      "#{e_module}|MaximumAge"          => "eligibilities#maximum_age#where maximum_age is not null and maximum_age <> ''",
      "#{e_module}|StudyPopulation"     => "eligibilities#population#where population is not null and population <> ''",
      "#{e_module}|SamplingMethod"      => "eligibilities#sampling_method#where sampling_method is not null and sampling_method <> ''",
    }
  end

  def contacts_location_module_hash
    cl_module = 'ProtocolSection|ContactsLocationsModule'
    {
      "#{cl_module}|CentralContactList|CentralContact|CentralContactName"                              => "central_contacts#name#where name is not null and name <> ''",
      "#{cl_module}|CentralContactList|CentralContact|CentralContactPhone"                             => "central_contacts#phone#where phone is not null and phone <> ''",
      "#{cl_module}|CentralContactList|CentralContact|CentralContactPhoneExt"                          => "central_contacts#phone#where phone ilike '% ext %' ",
      "#{cl_module}|CentralContactList|CentralContact|CentralContactEMail"                             => "central_contacts#email#where email is not null and email <> ''",

      "#{cl_module}|OverallOfficialList|OverallOfficial|OverallOfficialName"                           => "overall_officials#name#where name is not null and name <> ''",
      "#{cl_module}|OverallOfficialList|OverallOfficial|OverallOfficialAffiliation"                    => "overall_officials#affiliation#where affiliation is not null and affiliation <> ''",
      "#{cl_module}|OverallOfficialList|OverallOfficial|OverallOfficialRole"                           => "overall_officials#role#where role is not null and role <> ''",

      "#{cl_module}|LocationList|Location|LocationFacility"                                            => "facilities#name#where name is not null and name <> ''",
      "#{cl_module}|LocationList|Location|LocationStatus"                                              => "facilities#status#where status is not null and status <> ''",
      "#{cl_module}|LocationList|Location|LocationCity"                                                => "facilities#city#where city is not null and city <> ''",
      "#{cl_module}|LocationList|Location|LocationState"                                               => "facilities#state#where state is not null and state <> ''",
      "#{cl_module}|LocationList|Location|LocationZip"                                                 => "facilities#zip#where zip is not null and zip <> ''",
      "#{cl_module}|LocationList|Location|LocationCountry"                                             => "facilities#country#where country is not null and country <> ''",
      
      "#{cl_module}|LocationList|Location|LocationContactList|LocationContact|LocationContactName"     => "facility_contacts#name#where name is not null and name <> ''",
      "#{cl_module}|LocationList|Location|LocationContactList|LocationContact|LocationContactRole"     => "facility_contacts#contact_type#where contact_type is not null and contact_type <> ''",
      "#{cl_module}|LocationList|Location|LocationContactList|LocationContact|LocationContactPhone"    => "facility_contacts#phone#where phone is not null and phone <> ''",
      "#{cl_module}|LocationList|Location|LocationContactList|LocationContact|LocationContactPhoneExt" => "facility_contacts#phone#phone#where phone ilike '% ext %'",
      "#{cl_module}|LocationList|Location|LocationContactList|LocationContact|LocationContactEMail"    => "facility_contacts#email#where email is not null and email <> ''",
    }
  end

  def references_module_hash
    ref_module = 'ProtocolSection|ReferencesModule'
    {
      "#{ref_module}|ReferenceList|Reference|ReferencePMID"        => "study_references#pmid#where pmid is not null and pmid <> ''",
      "#{ref_module}|ReferenceList|Reference|ReferenceType"        => "study_references#reference_type#where reference_type is not null and reference_type <> ''",
      "#{ref_module}|ReferenceList|Reference|ReferenceCitation"    => "study_references#citation#where citation is not null and citation <> ''",
      
      "#{ref_module}|SeeAlsoLinkList|SeeAlsoLink|SeeAlsoLinkLabel" => "links#description#where description is not null and description <> ''",
      "#{ref_module}|SeeAlsoLinkList|SeeAlsoLink|SeeAlsoLinkURL"   => "links#url#where url is not null and url <> ''",

      "#{ref_module}|AvailIPDList|AvailIPD|AvailIPDId"             => "documents#document_id#where document_id is not null and document_id <> ''",
      "#{ref_module}|AvailIPDList|AvailIPD|AvailIPDType"           => "documents#document_type#where document_type is not null and document_type <> ''",
      "#{ref_module}|AvailIPDList|AvailIPD|AvailIPDURL"            => "documents#url#where url is not null and url <> ''",
      "#{ref_module}|AvailIPDList|AvailIPD|AvailIPDComment"        => "documents#comment#where comment is not null and comment <> ''",
    }
  end

  def ipd_sharing_module_hash
    ipd_module= 'ProtocolSection|IPDSharingStatementModule'
    {
      "#{ipd_module}|IPDSharing"                                => "studies#plan_to_share_ipd#where plan_to_share_ipd is not null and plan_to_share_ipd <> ''",
      "#{ipd_module}|IPDSharingDescription"                     => "studies#plan_to_share_ipd_description#where plan_to_share_ipd_description is not null and plan_to_share_ipd_description <> ''",
      "#{ipd_module}|IPDSharingInfoTypeList|IPDSharingInfoType" => "ipd_information_types#name#where name is not null and name <> ''",
      "#{ipd_module}|IPDSharingTimeFrame"                       => "studies#ipd_time_frame#where ipd_time_frame is not null and ipd_time_frame <> ''",
      "#{ipd_module}|IPDSharingAccessCriteria"                  => "studies#ipd_access_criteria#where ipd_access_criteria is not null and ipd_access_criteria <> ''",
      "#{ipd_module}|IPDSharingURL"                             => "studies#ipd_url#where ipd_url is not null and ipd_url <> ''",
    }
  end

  # Results section___________________________________________________________
  
  def participant_flow_module_hash
    pf_module = 'ResultsSection|ParticipantFlowModule'
    {
      "#{pf_module}|FlowPreAssignmentDetails"                     => "participant_flows#pre_assignment_details#where pre_assignment_details is not null and pre_assignment_details <> ''",
      "#{pf_module}|FlowRecruitmentDetails"                       => "participant_flows#recruitment_details#where recruitment_details is not null and recruitment_details <> ''",
      "#{pf_module}|FlowGroupList|FlowGroup|FlowGroupId"          => "result_groups#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> '' and result_type = 'Participant Flow'",
      "#{pf_module}|FlowGroupList|FlowGroup|FlowGroupTitle"       => "result_groups#title#where title is not null and title <> '' and result_type = 'Participant Flow'",
      "#{pf_module}|FlowGroupList|FlowGroup|FlowGroupDescription" => "result_groups#description#where description is not null and description <> '' and result_type = 'Participant Flow'",
      
      "#{pf_module}|FlowPeriodList|FlowPeriod|FlowPeriodTitle"                                                                                 => "milestones#period#where period is not null and period <> ''",
      "#{pf_module}|FlowPeriodList|FlowPeriod|FlowMilestoneList|FlowMilestone|FlowMilestoneType"                                               => "milestones#title#where title is not null and title <> ''",
      "#{pf_module}|FlowPeriodList|FlowPeriod|FlowMilestoneList|FlowMilestone|FlowAchievementList|FlowAchievement|FlowAchievementGroupId"      => "milestones#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> ''",
      "#{pf_module}|FlowPeriodList|FlowPeriod|FlowMilestoneList|FlowMilestone|FlowAchievementList|FlowAchievement|FlowAchievementComment"      => "milestones#description#where description is not null and description <> ''",
      "#{pf_module}|FlowPeriodList|FlowPeriod|FlowMilestoneList|FlowMilestone|FlowAchievementList|FlowAchievement|FlowAchievementNumSubjects"  => "milestones#count#where count is not null",
      

      "#{pf_module}|FlowPeriodList|FlowPeriod|FlowDropWithdrawList|FlowDropWithdraw|FlowDropWithdrawType"                                      => "drop_withdrawals#reason#where reason is not null and reason <> ''",
      "#{pf_module}|FlowPeriodList|FlowPeriod|FlowDropWithdrawList|FlowDropWithdraw|FlowReasonList|FlowReason|FlowReasonGroupId"               => "drop_withdrawals#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> ''",
      "#{pf_module}|FlowPeriodList|FlowPeriod|FlowDropWithdrawList|FlowDropWithdraw|FlowReasonList|FlowReason|FlowReasonNumSubjects"           => "drop_withdrawals#count#where count is not null",
    }
  end

  def baseline_characteristics_module_hash
    bc_module = 'ResultsSection|BaselineCharacteristicsModule'
    {
      "#{bc_module}|BaselinePopulationDescription"                            => "studies#baseline_population#where baseline_population is not null and baseline_population <> ''",
      "#{bc_module}|BaselineGroupList|BaselineGroup|BaselineGroupId"          => "result_groups#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> '' and result_type= 'Baseline'",
      "#{bc_module}|BaselineGroupList|BaselineGroup|BaselineGroupTitle"       => "result_groups#title#where title is not null and title <> '' and result_type= 'Baseline'",
      "#{bc_module}|BaselineGroupList|BaselineGroup|BaselineGroupDescription" => "result_groups#description#where description is not null and description <> '' and result_type= 'Baseline'",

      "#{bc_module}|BaselineDenomList|BaselineDenom|BaselineDenomUnits"                                                  => "baseline_counts#units#where units is not null and units <> ''",
      "#{bc_module}|BaselineDenomList|BaselineDenom|BaselineDenomCountList|BaselineDenomCount|BaselineDenomCountGroupId" => "baseline_counts#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> ''",
      "#{bc_module}|BaselineDenomList|BaselineDenom|BaselineDenomCountList|BaselineDenomCount|BaselineDenomCountValue"   => "baseline_counts#count#where count is not null",

      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasureTitle"          => "baseline_measurements#title#where title is not null and title <> ''",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasureDescription"    => "baseline_measurements#description#where description is not null and description <> ''",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasureParamType"      => "baseline_measurements#param_type#where param_type is not null and param_type <> ''",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasureDispersionType" => "baseline_measurements#dispersion_type#where dispersion_type is not null and dispersion_type <> ''",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasureUnitOfMeasure"  => "baseline_measurements#units#where units is not null and units <> ''",
      
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineClassTitle"                                                                                              => "baseline_measurements#classification#where classification is not null and classification <> ''",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineCategoryList|BaselineCategory|BaselineCategoryTitle"                                                     => "baseline_measurements#category#where category is not null and category <> ''",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineCategoryList|BaselineCategory|BaselineMeasurementList|BaselineMeasurement|BaselineMeasurementGroupId"    => "baseline_measurements#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> ''",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineCategoryList|BaselineCategory|BaselineMeasurementList|BaselineMeasurement|BaselineMeasurementValue"      => "baseline_measurements#param_value#where param_value is not null and param_value <> ''",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineCategoryList|BaselineCategory|BaselineMeasurementList|BaselineMeasurement|BaselineMeasurementSpread"     => "baseline_measurements#dispersion_value#where dispersion_value is not null and dispersion_value <> ''",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineCategoryList|BaselineCategory|BaselineMeasurementList|BaselineMeasurement|BaselineMeasurementLowerLimit" => "baseline_measurements#dispersion_lower_limit#where dispersion_lower_limit is not null",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineCategoryList|BaselineCategory|BaselineMeasurementList|BaselineMeasurement|BaselineMeasurementUpperLimit" => "baseline_measurements#dispersion_upper_limit#where dispersion_upper_limit is not null",
      "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineCategoryList|BaselineCategory|BaselineMeasurementList|BaselineMeasurement|BaselineMeasurementComment"    => "baseline_measurements#explanation_of_na#where explanation_of_na is not null and explanation_of_na <> ''",
    }
  end

  def outcome_measures_module_hash
    om_module = "ResultsSection|OutcomeMeasuresModule"
    {
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureType"                  => "outcomes#outcome_type#where outcome_type is not null and outcome_type <> ''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureTitle"                 => "outcomes#title#where title is not null and title <> ''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureDescription"           => "outcomes#description#where title is not null and title <> ''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasurePopulationDescription" => "outcomes#population#where title is not null and title <> ''",

      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureAnticipatedPostingDate" => "outcomes#anticipated_posting_date#where anticipated_posting_date is not null",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureParamType"              => "outcomes#param_type#where param_type is not null and param_type <> ''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureDispersionType"         => "outcomes#dispersion_type#where dispersion_type is not null and dispersion_type <> ''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureUnitOfMeasure"          => "outcomes#units#where units is not null and units <> ''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureTimeFrame"              => "outcomes#time_frame#where time_frame is not null and time_frame <> ''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureTypeUnitsAnalyzed"      => "outcomes#units_analyzed#where units_analyzed is not null and units_analyzed <> ''",
      
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeGroupList|OutcomeGroup|OutcomeGroupId"          => "result_groups#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> '' and result_type= 'Outcome'",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeGroupList|OutcomeGroup|OutcomeGroupTitle"       => "result_groups#title#where title is not null and title <> '' and result_type= 'Outcome'",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeGroupList|OutcomeGroup|OutcomeGroupDescription" => "result_groups#description#where title is not null and description <> '' and result_type= 'Outcome'",

      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeDenomList|OutcomeDenom|OutcomeDenomUnits"                                                                  => "outcome_counts#units#where units is not null and units <> ''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeDenomList|OutcomeDenom|OutcomeDenomCountList|OutcomeDenomCount|OutcomeDenomCountGroupId" => "outcome_counts#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> ''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeDenomList|OutcomeDenom|OutcomeDenomCountList|OutcomeDenomCount|OutcomeDenomCountValue"   => "outcome_counts#count#where count is not null",
      
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeClassTitle" => "outcome_measurements#classification#where classification is not null and classification <> ''",
      
      
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeCategoryList|OutcomeCategory|OutcomeCategoryTitle"                                                   => "outcome_measurements#category#where category is not null and category <> ''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeCategoryList|OutcomeCategory|OutcomeMeasurementList|OutcomeMeasurement|OutcomeMeasurementGroupId"    => "outcome_measurements#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeCategoryList|OutcomeCategory|OutcomeMeasurementList|OutcomeMeasurement|OutcomeMeasurementValue"      => "outcome_measurements#param_value#where param_value is not null and param_value <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeCategoryList|OutcomeCategory|OutcomeMeasurementList|OutcomeMeasurement|OutcomeMeasurementSpread"     => "outcome_measurements#dispersion_value#where dispersion_value is not null and dispersion_value <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeCategoryList|OutcomeCategory|OutcomeMeasurementList|OutcomeMeasurement|OutcomeMeasurementLowerLimit" => "outcome_measurements#dispersion_lower_limit#where dispersion_lower_limit is not null",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeCategoryList|OutcomeCategory|OutcomeMeasurementList|OutcomeMeasurement|OutcomeMeasurementUpperLimit" => "outcome_measurements#dispersion_upper_limit#where dispersion_upper_limit is not null ",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeCategoryList|OutcomeCategory|OutcomeMeasurementList|OutcomeMeasurement|OutcomeMeasurementComment"    => "outcome_measurements#explanation_of_na#where explanation_of_na is not null and explanation_of_na <>''",
      
      
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisGroupIdList|OutcomeAnalysisGroupId" => "outcome_analysis_groups#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisGroupDescription"                   => "outcome_analyses#groups_description#where groups_description is not null and groups_description <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisNonInferiorityType"                 => "outcome_analyses#non_inferiority_type#where non_inferiority_type is not null and non_inferiority_type <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisNonInferiorityComment"              => "outcome_analyses#non_inferiority_description#where non_inferiority_description is not null and non_inferiority_description <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisPValue"                             => "outcome_analyses#p_value_modifier#where p_value_modifier is not null and p_value_modifier <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisPValueComment"                      => "outcome_analyses#p_value_description#where p_value_description is not null and p_value_description <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisStatisticalMethod"                  => "outcome_analyses#method#where method is not null and method <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisStatisticalComment"                 => "outcome_analyses#method_description#where method_description is not null and method_description <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisParamType"                          => "outcome_analyses#param_type#where param_type is not null and param_type <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisParamValue"                         => "outcome_analyses#param_value#where param_value is not null",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisCIPctValue"                         => "outcome_analyses#ci_percent#where ci_percent is not null",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisCINumSides"                         => "outcome_analyses#ci_n_sides#where ci_n_sides is not null and ci_n_sides <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisCILowerLimit"                       => "outcome_analyses#ci_lower_limit#where ci_lower_limit is not null",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisCIUpperLimit"                       => "outcome_analyses#ci_upper_limit#where ci_upper_limit is not null",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisCIUpperLimitComment"                => "outcome_analyses#ci_upper_limit_na_comment#where ci_upper_limit_na_comment is not null and ci_upper_limit_na_comment <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisDispersionType"                     => "outcome_analyses#dispersion_type#where dispersion_type is not null and dispersion_type <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisDispersionValue"                    => "outcome_analyses#dispersion_value#where dispersion_value is not null",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisEstimateComment"                    => "outcome_analyses#estimate_description#where estimate_description is not null and estimate_description <>''",
      "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisOtherAnalysisDescription"           => "outcome_analyses#other_analysis_description#where other_analysis_description is not null and other_analysis_description <>''",
    }
  end

  def adverse_events_module_hash
    ae_module = 'ResultsSection|AdverseEventsModule'
    {
      "#{ae_module}|EventsFrequencyThreshold" => "reported_events#frequency_threshold#where frequency_threshold is not null",
      "#{ae_module}|EventsTimeFrame"          => "reported_events#time_frame#where time_frame is not null and time_frame <> ''",
      "#{ae_module}|EventsDescription"        => "reported_events#description#where description is not null and description <> ''",
      
      "#{ae_module}|EventGroupList|EventGroup|EventGroupId"                 => "reported_event_totals#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> ''",
      "#{ae_module}|EventGroupList|EventGroup|EventGroupDeathsNumAffected"  => "reported_event_totals#subjects_affected#where subjects_affected is not null and classification = 'Total, all-cause mortality'",
      "#{ae_module}|EventGroupList|EventGroup|EventGroupDeathsNumAtRisk"    => "reported_event_totals#subjects_at_risk#where subjects_at_risk is not null and classification = 'Total, all-cause mortality'",
      "#{ae_module}|EventGroupList|EventGroup|EventGroupSeriousNumAffected" => "reported_event_totals#subjects_affected#where subjects_affected is not null and event_type ilike 'serious'",
      "#{ae_module}|EventGroupList|EventGroup|EventGroupSeriousNumAtRisk"   => "reported_event_totals#subjects_at_risk#where subjects_at_risk is not null and event_type ilike 'serious'",
      "#{ae_module}|EventGroupList|EventGroup|EventGroupOtherNumAffected"   => "reported_event_totals#subjects_affected#where subjects_affected is not null and event_type ilike 'other'",
      "#{ae_module}|EventGroupList|EventGroup|EventGroupOtherNumAtRisk"     => "reported_event_totals#subjects_at_risk#where subjects_at_risk is not null and event_type ilike 'other'",

      "#{ae_module}|SeriousEventList|SeriousEvent|SeriousEventTerm"                => "reported_events#adverse_event_term#where adverse_event_term is not null and adverse_event_term <> '' and event_type ilike 'serious'",
      "#{ae_module}|SeriousEventList|SeriousEvent|SeriousEventOrganSystem"         => "reported_events#organ_system#where organ_system is not null and organ_system <> '' and event_type ilike 'serious'",
      "#{ae_module}|SeriousEventList|SeriousEvent|SeriousEventSourceVocabulary"    => "reported_events#vocab#where vocab is not null and vocab <> '' and event_type ilike 'serious'",
      "#{ae_module}|SeriousEventList|SeriousEvent|SeriousEventAssessmentType"      => "reported_events#assessment#where assessment is not null and assessment <> '' and event_type ilike 'serious'",

      "#{ae_module}|SeriousEventList|SeriousEvent|SeriousEventStatsList|SeriousEventStats|SeriousEventStatsGroupId"     => "reported_events#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> '' and event_type ilike 'serious'",
      "#{ae_module}|SeriousEventList|SeriousEvent|SeriousEventStatsList|SeriousEventStats|SeriousEventStatsNumEvents"   => "reported_events#event_count#where event_count is not null and event_type ilike 'serious'",
      "#{ae_module}|SeriousEventList|SeriousEvent|SeriousEventStatsList|SeriousEventStats|SeriousEventStatsNumAffected" => "reported_events#subjects_affected#where subjects_affected is not null and event_type ilike 'serious'",
      "#{ae_module}|SeriousEventList|SeriousEvent|SeriousEventStatsList|SeriousEventStats|SeriousEventStatsNumAtRisk"   => "reported_events#subjects_at_risk#where subjects_at_risk is not null and event_type ilike 'serious'",

     
      "#{ae_module}|OtherEventList|OtherEvent|OtherEventTerm"                => "reported_events#adverse_event_term#where adverse_event_term is not null and adverse_event_term <> '' and event_type ilike 'other'",
      "#{ae_module}|OtherEventList|OtherEvent|OtherEventOrganSystem"         => "reported_events#organ_system#where organ_system is not null and organ_system <> '' and event_type ilike 'other'",
      "#{ae_module}|OtherEventList|OtherEvent|OtherEventSourceVocabulary"    => "reported_events#vocab#where vocab is not null and vocab <> '' and event_type ilike 'other'",
      "#{ae_module}|OtherEventList|OtherEvent|OtherEventAssessmentType"      => "reported_events#assessment#where assessment is not null and assessment <> '' and event_type ilike 'other'",

      "#{ae_module}|OtherEventList|OtherEvent|OtherEventStatsList|OtherEventStats|OtherEventStatsGroupId"     => "reported_events#ctgov_group_code#where ctgov_group_code is not null and ctgov_group_code <> '' and event_type ilike 'other'",
      "#{ae_module}|OtherEventList|OtherEvent|OtherEventStatsList|OtherEventStats|OtherEventStatsNumEvents"   => "reported_events#event_count#where event_count is not null and event_type ilike 'other'",
      "#{ae_module}|OtherEventList|OtherEvent|OtherEventStatsList|OtherEventStats|OtherEventStatsNumAffected" => "reported_events#subjects_affected#where subjects_affected is not null and event_type ilike 'other'",
      "#{ae_module}|OtherEventList|OtherEvent|OtherEventStatsList|OtherEventStats|OtherEventStatsNumAtRisk"   => "reported_events#subjects_at_risk#where subjects_at_risk is not null and event_type ilike 'other'",
    }
  end

  def more_info_module_hash
    mi_module = 'ResultsSection|MoreInfoModule'
    {
      "#{mi_module}|CertainAgreement|AgreementPISponsorEmployee" => "result_agreements#pi_employee#where pi_employee is not null and pi_employee <> ''",
      "#{mi_module}|CertainAgreement|AgreementRestrictionType" => "result_agreements#restriction_type#where restriction_type is not null and restriction_type <> ''",
      "#{mi_module}|CertainAgreement|AgreementRestrictiveAgreement" => "result_agreements#restrictive_agreement#where restrictive_agreement is not null and restrictive_agreement <> ''",
      "#{mi_module}|CertainAgreement|AgreementOtherDetails" => "result_agreements#other_details#where other_details is not null and other_details <> ''",

      "#{mi_module}|PointOfContact|PointOfContactTitle" => "result_contacts#name#where name is not null and name <> ''",
      "#{mi_module}|PointOfContact|PointOfContactOrganization" => "result_contacts#organization#where organization is not null and organization <> ''",
      "#{mi_module}|PointOfContact|PointOfContactEMail" => "result_contacts#email#where email is not null and email <> ''",
      "#{mi_module}|PointOfContact|PointOfContactPhone" => "result_contacts#phone#where phone is not null and phone <> ''",
      "#{mi_module}|PointOfContact|PointOfContactPhoneExt" => "result_contacts#phone#where phone is not null and phone <> '' and phone ilike '%ext%'",
    }
  end

  # Annotation section___________________________________________________________

  def annotation_module_hash
    a_module = 'AnnotationSection|AnnotationModule'
    {
      "#{a_module}|UnpostedAnnotation|UnpostedEventList|UnpostedEvent|UnpostedEventType" => "pending_results#event#where event is not null and event <> ''",
      "#{a_module}|UnpostedAnnotation|UnpostedEventList|UnpostedEvent|UnpostedEventDate" => "pending_results#event_date_description#where event_date_description is not null and event_date_description <> ''",
    }
  end

  # Document section___________________________________________________________

  def large_document_module_hash
    ld_module = 'DocumentSection|LargeDocumentModule'
    {
      "#{ld_module}|LargeDocList|LargeDoc|LargeDocHasProtocol" => "provided_documents#has_protocol#where has_protocol is not null",
      "#{ld_module}|LargeDocList|LargeDoc|LargeDocHasSAP" => "provided_documents#has_sap#where has_sap is not null",
      "#{ld_module}|LargeDocList|LargeDoc|LargeDocHasICF" => "provided_documents#has_icf#where has_icf is not null",
      "#{ld_module}|LargeDocList|LargeDoc|LargeDocLabel" => "provided_documents#document_type#where document_type is not null and document_type <> ''",
      "#{ld_module}|LargeDocList|LargeDoc|LargeDocDate" => "provided_documents#document_date#where document_date is not null",
    }
  end

  # Derived section___________________________________________________________

  def misc_info_module_hash
    misc_module = 'DerivedSection|MiscInfoModule'
    {
      "#{misc_module}|RemovedCountryList|RemovedCountry" => "countries#name#where removed = true",
    }
  end

  def condition_browse_module_hash
    cb_module = 'DerivedSection|ConditionBrowseModule'
    {
      "#{cb_module}|ConditionMeshList|ConditionMesh|ConditionMeshTerm" => "browse_conditions#mesh_term#where mesh_term is not null and mesh_term <>'' and mesh_type = 'mesh-list'",
      "#{cb_module}|ConditionAncestorList|ConditionAncestor|ConditionAncestorTerm" => "browse_conditions#mesh_term#where mesh_term is not null and mesh_term <>'' and mesh_type = 'mesh-ancestor'",
    }
  end

  def intervention_browse_module_hash
    ib_module = 'DerivedSection|InterventionBrowseModule'
    {
      "#{ib_module}|InterventionMeshList|InterventionMesh|InterventionMeshTerm" => "browse_interventions#mesh_term#where mesh_term is not null and mesh_term <>'' and mesh_type = 'mesh-list'",
      "#{ib_module}|InterventionAncestorList|InterventionAncestor|InterventionAncestorTerm" => "browse_interventions#mesh_term#where mesh_term is not null and mesh_term <>'' and mesh_type = 'mesh-ancestor'",
    }
  end
  
  # for result_groups you should filter by result_type
  #  result_types = ["Baseline", "Outcome", "Participant Flow", "Reported Event"]
  
  # listed below are selectors that don't point to any tables/columns in our database

  # ID Module__________________________________
  # "#{id_module}|OrgStudyIdInfo|OrgStudyIdType"
  # "#{id_module}|OrgStudyIdInfo|OrgStudyIdDomain"
  # "#{id_module}|OrgStudyIdInfo|OrgStudyIdLink"
  # "#{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdType"
  # "#{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdDomain"
  # "#{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdLink"
  # "#{id_module}|Organization|OrgClass"

  # Status Module__________________________________ 
  # "#{status_module}|DelayedPosting"
  # "#{status_module}|ExpandedAccessInfo|ExpandedAccessNCTId"
  # "#{status_module}|ExpandedAccessInfo|ExpandedAccessStatusForNCTId"
  # "#{status_module}|ResultsFirstPostedQCCommentsDateStruct|ResultsFirstPostedQCCommentsDate"
  # "#{status_module}|ResultsFirstPostedQCCommentsDateStruct|ResultsFirstPostedQCCommentsDateType"

  # Sponsor Collaborator Module__________________________________
  # "#{sc_module}|ResponsibleParty|ResponsiblePartyOldNameTitle"

  # Oversight Module__________________________________
  # "#{over_module}|FDAAA801Violation"

  # Arms Interventions Module__________________________________
  # "#{ai_module}|ArmGroupList|ArmGroup|ArmGroupInterventionList|ArmGroupInterventionName"

  # Eligibility Module__________________________________
  # "#{e_module}|StdAgeList"

  # Contacts Location Module__________________________________
  # "#{cl_module}|CentralContactList|CentralContactRole"

  # References Module__________________________________
  # "#{ref_module}|ReferenceList|Reference|RetractionList|Retraction|RetractionPMID"
  # "#{ref_module}|ReferenceList|Reference|RetractionList|Retraction|RetractionSource" 

  # Participant Flow Module__________________________________
  # "#{pf_module}|FlowTypeUnitsAnalyzed"
  # "#{pf_module}|FlowPeriodList|FlowPeriod|FlowMilestoneList|FlowMilestone|FlowMilestoneComment"
  # "#{pf_module}|FlowPeriodList|FlowPeriod|FlowMilestoneList|FlowMilestone|FlowAchievementList|FlowAchievement|FlowAchievementNumUnits" 
  # "#{pf_module}|FlowPeriodList|FlowPeriod|FlowDropWithdrawList|FlowDropWithdraw|FlowDropWithdrawComment"
  # "#{pf_module}|FlowPeriodList|FlowPeriod|FlowDropWithdrawList|FlowDropWithdraw|FlowReasonList|FlowReason|FlowReasonComment"
  # "#{pf_module}|FlowPeriodList|FlowPeriod|FlowDropWithdrawList|FlowDropWithdraw|FlowReasonList|FlowReason|FlowReasonNumUnits"

  # Baseline Characteristics Module__________________________________
  # "#{bc_module}|BaselineTypeUnitsAnalyzed"
  # "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasurePopulationDescription"
  # "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasureCalculatePct"
  # "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasureDenomUnitsSelected"
  # "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasureDenomList|BaselineMeasureDenom|BaselineMeasureDenomUnits"
  # "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasureDenomList|BaselineMeasureDenom|BaselineMeasureDenomCountList|BaselineMeasureDenomCount|BaselineMeasureDenomCountGroupId"
  # "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineMeasureDenomList|BaselineMeasureDenom|BaselineMeasureDenomCountList|BaselineMeasureDenomCount|BaselineMeasureDenomCountValue"
  # "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineClassDenomList|BaselineClassDenom|BaselineClassDenomUnits"
  # "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineClassDenomList|BaselineClassDenom|BaselineClassDenomCountList|BaselineClassDenomCount|BaselineClassDenomCountGroupId"
  # "#{bc_module}|BaselineMeasureList|BaselineMeasure|BaselineClassList|BaselineClass|BaselineClassDenomList|BaselineClassDenom|BaselineClassDenomCountList|BaselineClassDenomCount|BaselineClassDenomCountValue"
  
  # Outcome Measures Module__________________________________
  # "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureReportingStatus"
  # "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureCalculatePct"
  # "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeMeasureDenomUnitsSelected"
  # "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeClassDenomList|OutcomeClassDenom|OutcomeClassDenomUnits"
  # "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeClassDenomList|OutcomeClassDenom|OutcomeClassDenomCountList|OutcomeClassDenomCount|OutcomeClassDenomCountGroupId"
  # "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeClassList|OutcomeClass|OutcomeClassDenomList|OutcomeClassDenom|OutcomeClassDenomCountList|OutcomeClassDenomCount|OutcomeClassDenomCountValue" 
  # "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisTestedNonInferiority"
  # "#{om_module}|OutcomeMeasureList|OutcomeMeasure|OutcomeAnalysisList|OutcomeAnalysis|OutcomeAnalysisCILowerLimitComment"
  
  # Adverse Events Module__________________________________
  # "#{ae_module}|EventGroupList|EventGroup|EventGroupTitle"
  # "#{ae_module}|EventGroupList|EventGroup|EventGroupDescription"
  # "#{ae_module}|SeriousEventList|SeriousEvent|SeriousEventNotes"
  # "#{ae_module}|OtherEventList|OtherEvent|OtherEventNotes"

  # More Information Module__________________________________
  # "#{mi_module}|LimitationsAndCaveatsDescription"

  # Annotation Module__________________________________
  # "#{a_module}|UnpostedAnnotation|UnpostedResponsibleParty"

  # Large Documents Module__________________________________
  # "#{ld_module}|LargeDocList|LargeDoc|LargeDocTypeAbbrev"
  # "#{ld_module}|LargeDocList|LargeDoc|LargeDocUploadDate"
  # "#{ld_module}|LargeDocList|LargeDoc|LargeDocFilename"

  # Misc Info Module__________________________________
  # "#{misc_module}|VersionHolder"

  # Condition Browse Module__________________________________
  # "#{cb_module}|ConditionMeshList|ConditionMesh|ConditionMeshId"
  # "#{cb_module}|ConditionAncestorList|ConditionAncestor|ConditionAncestorId"
  # "#{cb_module}|ConditionBrowseLeafList|ConditionBrowseLeaf|ConditionBrowseLeafId"
  # "#{cb_module}|ConditionBrowseLeafList|ConditionBrowseLeaf|ConditionBrowseLeafName"
  # "#{cb_module}|ConditionBrowseLeafList|ConditionBrowseLeaf|ConditionBrowseLeafAsFound"
  # "#{cb_module}|ConditionBrowseLeafList|ConditionBrowseLeaf|ConditionBrowseLeafRelevance"
  # "#{cb_module}|ConditionBrowseBranchList|ConditionBrowseBranch|ConditionBrowseBranchAbbrev"
  # "#{cb_module}|ConditionBrowseBranchList|ConditionBrowseBranch|ConditionBrowseBranchName"

  # Intervention Browse Module__________________________________
  # "#{ib_module}|InterventionMeshList|InterventionMesh|InterventionMeshId"
  # "#{ib_module}|InterventionAncestorList|InterventionAncestor|InterventionAncestorId"
  # "#{ib_module}|InterventionBrowseLeafList|InterventionBrowseLeaf|InterventionBrowseLeafId"
  # "#{ib_module}|InterventionBrowseLeafList|InterventionBrowseLeaf|InterventionBrowseLeafName"
  # "#{ib_module}|InterventionBrowseLeafList|InterventionBrowseLeaf|InterventionBrowseLeafAsFound"
  # "#{ib_module}|InterventionBrowseLeafList|InterventionBrowseLeaf|InterventionBrowseLeafRelevance"
  # "#{ib_module}|InterventionBrowseBranchList|InterventionBrowseBranch|InterventionBrowseBranchAbbrev"
  # "#{ib_module}|InterventionBrowseBranchList|InterventionBrowseBranch|InterventionBrowseBranchName"

end
