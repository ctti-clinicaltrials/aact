class Verifier < ActiveRecord::Base
  APIJSON =  ClinicalTrialsApi.study_statistics

  def self.tester
    found = Verifier.last 
    unless found
      found = Verifier.new.set_source
    end
    found.verify({schema: 'ctgov'})
  end

  def self.refresh(params={schema: 'ctgov'})
    Verifier.destroy_all
    Verifier.new.set_source.verify(params)
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
  
  def set_source
    source = APIJSON.dig('StudyStatistics', "ElmtDefs", "Study")
  end

  def verify(params={schema: 'ctgov'})
    set_schema(params[:schema])
    
    return if self.source.blank?

    differences = []
    # I first add the count so that we can know if the differences might be caused by having a different amount of studies
    source_study_counts = self.source.dig('nInstances')
    db_study_counts = Study.count
    differences<< {source_study_count: source_study_counts, db_study_count:  db_study_counts} unless same?(source_study_counts,  db_study_counts)
    
    # Now I add the differences for each selector
    all_locations.each do |key,value|
      found = diff_hash(key, value)
      differences << found unless found.blank?
    end

    last_run = Time.now
    self.save

    return differences
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
  #  id_module_hash.merge!(status_module_hash)
                  # .merge!(sponsor_collaborator_module_hash)
                  # .merge!(oversight_module_hash)
                  # .merge!(description_module_hash)
                  # .merge!(conditions_module_hash)
                  # .merge!(design_module_hash)
                  # .merge!(arms_interventions_module_hash)
                  # .merge!(outcomes_module_hash) 
                  # .merge!(eligibility_module_hash)
                  # .merge!(contacts_location_module_hash)
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
    # contacts_location_module_hash                
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
    om_module = 'ProtocolSection|OversightModule'
    {
      "#{om_module}|OversightHasDMC"      => 'studies#has_dmc#where has_dmc is not null',
      "#{om_module}|IsFDARegulatedDrug"   => 'studies#is_fda_regulated_drug#where is_fda_regulated_drug is not null',
      "#{om_module}|IsFDARegulatedDevice" => 'studies#is_fda_regulated_device#where is_fda_regulated_device is not null',
      "#{om_module}|IsUnapprovedDevice"   => 'studies#is_unapproved_device#where is_unapproved_device is not null',
      "#{om_module}|IsPPSD"               => 'studies#is_ppsd#where is_ppsd is not null',
      "#{om_module}|IsUSExport"           => 'studies#is_us_export#where is_us_export is not null',
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
      "#{design_module}|StudyType"                                                        => "studies#study_type#where study_type is not null and study_type <>''",
      
      "#{design_module}|ExpandedAccessTypes|ExpAccTypeIndividual"                         => 'studies#expanded_access_type_individual#where expanded_access_type_individual is not null',
      "#{design_module}|ExpandedAccessTypes|ExpAccTypeIntermediate"                       => 'studies#expanded_access_type_intermediate#where expanded_access_type_intermediate is not null',
      "#{design_module}|ExpandedAccessTypes|ExpAccTypeTreatment"                          => 'studies#expanded_access_type_treatment#where expanded_access_type_treatment is not null',
      
      "#{design_module}|PatientRegistry"                                                  => "studies#study_type#where study_type iLIKE '%Patient Registry%'",
      "#{design_module}|TargetDuration"                                                   => "studies#target_duration#where target_duration is not null and target_duration <>''",
      "#{design_module}|PhaseList|Phase"                                                  => "studies#phase#where phase is not null and phase <>''",
      
      "#{design_module}|DesignInfo|DesignAllocation"                                      => "designs#allocation#where allocation is not null and allocation <>''",
      "#{design_module}|DesignInfo|DesignInterventionModel"                               => "designs#intervention_model#where intervention_model is not null and intervention_model <>''",
      "#{design_module}|DesignInfo|DesignInterventionModelDescription"                    => "designs#intervention_model_description#where intervention_model_description is not null and intervention_model_description <>''",
      "#{design_module}|DesignInfo|DesignPrimaryPurpose"                                  => "designs#primary_purpose#where primary_purpose is not null and primary_purpose <>''",
      "#{design_module}|DesignInfo|DesignObservationalModelList|DesignObservationalModel" => "designs#observational_model#where observational_model is not null and observational_model <>''",
      "#{design_module}|DesignInfo|DesignTimePerspectiveList|DesignTimePerspective"       => "designs#time_perspective#where time_perspective is not null and time_perspective <>''",
      "#{design_module}|DesignInfo|DesignMaskingInfo|DesignMasking"                       => "designs#masking#where masking is not null and masking <>''",
      "#{design_module}|DesignInfo|DesignMaskingInfo|DesignMaskingDescription"            => "designs#masking_description#where masking_description is not null and masking_description <>''",
      "#{design_module}|DesignInfo|DesignMaskingInfo|DesignWhoMaskedList|DesignWhoMasked" => 'designs#CONCAT(subject_masked,caregiver_masked,investigator_masked,outcomes_assessor_masked)# where COALESCE(subject_masked,caregiver_masked,investigator_masked,outcomes_assessor_masked) is not null',
      
      "#{design_module}|BioSpec|BioSpecRetention"                                         => "studies#biospec_retention#where biospec_retention is not null and biospec_retention <>''",
      "#{design_module}|BioSpec|BioSpecDescription"                                       => "studies#biospec_description#where biospec_description is not null and biospec_description <>''",
      
      "#{design_module}|EnrollmentInfo|EnrollmentCount"                                   => 'studies#enrollment#where enrollment is not null',
      "#{design_module}|EnrollmentInfo|EnrollmentType"                                    => "studies#enrollment_type#where enrollment_type is not null and enrollment_type <>''",
    }
  end

  def arms_interventions_module_hash
    ai_module = 'ProtocolSection|ArmsInterventionsModule'
    {
      "#{ai_module}|ArmGroupList|ArmGroup|ArmGroupLabel"                                                   => "design_groups#title#where title is not null and title <>''",
      "#{ai_module}|ArmGroupList|ArmGroup|ArmGroupType"                                                    => "design_groups#group_type#where group_type is not null and group_type <>''",
      "#{ai_module}|ArmGroupList|ArmGroup|ArmGroupDescription"                                             => "design_groups#description#where description is not null and description <>''",
      
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
      "#{cl_module}|CentralContactList|CentralContactName" => "central_contacts#name#where name is not null and name <> ''"
    }
  end

#   [{:source_study_count=>393739, :db_study_count=>393436},
#  {:source=>"ProtocolSection|DesignModule|DesignInfo|DesignMaskingInfo|DesignWhoMaskedList|DesignWhoMasked",
#   :destination=>"designs#CONCAT(subject_masked,caregiver_masked, investigator_masked, outcomes_assessor_masked)",
#   :source_instances=>286512,
#   :destination_instances=>393436,
#   :source_unique_values=>4,
#   :destination_unique_values=>5}]

# {:source_study_count=>393739, :db_study_count=>393436},
#  {:source=>"ProtocolSection|DesignModule|DesignInfo|DesignMaskingInfo|DesignWhoMaskedList|DesignWhoMasked",
#   :destination=>
#    "designs#CONCAT(subject_masked,caregiver_masked,investigator_masked,outcomes_assessor_masked)# where COALESCE(subject_masked,caregiver_masked,investigator_masked,outcomes_assessor_masked) is not null",
#   :source_instances=>286512,
#   :destination_instances=>124195,
#   :source_unique_values=>4,
#   :destination_unique_values=>4}]

# [{:source_study_count=>393739, :db_study_count=>393436},
#  {:source=>"ProtocolSection|DesignModule|DesignInfo|DesignMaskingInfo|DesignWhoMaskedList|DesignWhoMasked",
#   :destination=>
#    "designs#CONCAT(subject_masked,caregiver_masked,investigator_masked,outcomes_assessor_masked)# where subject_masked is not null and caregiver_masked is not null and investigator_masked is not null and outcomes_assessor_masked is not null",
#   :source_instances=>286512,
#   :destination_instances=>28677,
#   :source_unique_values=>4,
#   :destination_unique_values=>1}]

  
  # selectors that aren't in the database
  # "#{id_module}|OrgStudyIdInfo|OrgStudyIdType"
  # "#{id_module}|OrgStudyIdInfo|OrgStudyIdDomain"
  # "#{id_module}|OrgStudyIdInfo|OrgStudyIdLink"
  # "#{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdType"
  # "#{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdDomain"
  # "#{id_module}|SecondaryIdInfoList|SecondaryIdInfo|SecondaryIdLink"
  # "#{id_module}|Organization|OrgClass"
  # "#{status_module}|DelayedPosting"
  # "#{status_module}|ExpandedAccessInfo|ExpandedAccessNCTId"
  # "#{status_module}|ExpandedAccessInfo|ExpandedAccessStatusForNCTId"
  # "#{status_module}|ResultsFirstPostedQCCommentsDateStruct|ResultsFirstPostedQCCommentsDate"
  # "#{status_module}|ResultsFirstPostedQCCommentsDateStruct|ResultsFirstPostedQCCommentsDateType"
  # "#{sc_module}|ResponsibleParty|ResponsiblePartyOldNameTitle"
  # "#{om_module}|FDAAA801Violation"
  # "#{ai_module}|ArmGroupList|ArmGroup|ArmGroupInterventionList|ArmGroupInterventionName"
  # "#{e_module}|StdAgeList"
  
end
