require 'open-uri'
require 'fileutils'
# require 'zip'
include ActionView::Helpers::DateHelper
class StudyJsonRecord < ActiveRecord::Base

  def self.root_dir
    "#{Rails.public_path}/static"
  end

  def self.json_file_directory
    FileUtils.mkdir_p "#{root_dir}/json_downloads"
    "#{root_dir}/json_downloads"
  end

  def self.download_all_studies(url='https://ClinicalTrials.gov/AllAPIJSON.zip')
    tries ||= 5

    file_name="#{json_file_directory}/#{Time.zone.now.strftime("%Y%m%d-%H")}.zip"
    file = File.new file_name, 'w'
    begin
      if tries < 5
        `wget -c #{url} -O #{file.path}`
      else
        `wget #{url} -O #{file.path}`
      end
    rescue Errno::ECONNRESET => e
      if (tries -=1) > 0
        puts "  download failed.  trying again..."
        retry
      end
    end
    file.binmode
    file.size
    file
  end

  def self.save_all_downloaded_studies
    start_time = Time.current
    study_download = download_all_studies
    # finshed in about 12 hours
    # total number we have 326614
    Zip::File.open(study_download.path) do |unzipped_folders|
      puts "unzipped folders"
      original_count = unzipped_folders.size
      count_down = original_count
      unzipped_folders.each do |file|
        begin 
        contents = file.get_input_stream.read
        json = JSON.parse(contents)
        rescue 
          next unless json
        end

        study = json['FullStudy']
        next unless study

        save_single_study(study)
        nct_id = study['Study']['ProtocolSection']['IdentificationModule']['NCTId']
        puts "added NCTId #{nct_id} study_json_record: #{count_down} of #{original_count}"
        count_down -= 1
      end  
    end
    seconds = Time.now - start_time
    puts "finshed in #{time_ago_in_words(start_time)}"
    puts "total number we have #{StudyJsonRecord.count}"
  end

  def self.save_all_api_studies
    # Current Study Json Record Count 326614
    # finshed in about 17 hours
    # total number we should have 326612
    start_time = Time.current
    first_batch = json_data
    save_study_records(first_batch['FullStudiesResponse']['FullStudies'])
    # total_number is the number of studies available, meaning the total number in their database
    total_number = first_batch['FullStudiesResponse']['NStudiesAvail']
    # since I already saved the first hundred studies I start the loop after that point
    # studies must be retrieved in batches of 99,
    # using min and max to determine the study to start with and the study to end with respectively (in that batch)
    min = 101
    max = 200

    limit = (total_number/100.0).ceil
    
    for x in 1..limit
      puts "batch #{x}"
      fetch_studies(min, max)
      min += 100
      max += 100
      puts "Current Study Json Record Count #{StudyJsonRecord.count}"
      sleep 1
    end
    seconds = Time.now - start_time
    puts "finshed in #{time_ago_in_words(start_time)}"
    puts "total number we should have #{total_number}"
    puts "total number we have #{StudyJsonRecord.count}"
  end

  def self.fetch_studies(min=1, max=100)
    begin
      retries ||= 0
      puts "try ##{ retries }"
      # incremental_url = "https://clinicaltrials.gov/api/query/full_studies?expr=AREA[LastUpdatePostDate]RANGE[01/01/2020,%20MAX]&fmt=json"
      url="https://clinicaltrials.gov/api/query/full_studies?expr=&min_rnk=#{min}&max_rnk=#{max}&fmt=json"
      data = json_data(url)['FullStudiesResponse']['FullStudies']
      save_study_records(data)
    rescue
      retry if (retries += 1) < 6
    end
  end

  def self.save_study_records(study_batch)
    study_batch.each do |study_data|
      save_single_study(study_data)
    end
  end

  def self.save_single_study(study_data)
    nct_id = study_data['Study']['ProtocolSection']['IdentificationModule']['NCTId']
    record = StudyJsonRecord.find_by(nct_id: nct_id) || StudyJsonRecord.new(nct_id: nct_id)
    record.content = study_data
    record.saved_study_at = nil 
    unless record.save
      puts "failed to save #{nct_id}"
    end
  end

  def self.json_data(url='https://clinicaltrials.gov/api/query/full_studies?expr=&min_rnk=1&max_rnk=100&fmt=json')
    puts url
    page = open(url)
    JSON.parse(page.read)
  end

  def key_check(key)
    key ||= {}
  end

  def get_boolean(val)
    return nil unless val
    return true if val.downcase=='yes'||val.downcase=='y'||val.downcase=='true'
    return false if val.downcase=='no'||val.downcase=='n'||val.downcase=='false'
  end

  def get_date(str)
    Date.parse(str) if str
  end

  def convert_date(str)
    return nil unless str
    return str.to_date.end_of_month if is_missing_the_day?(str)
    
    get_date(str)
  end

  def is_missing_the_day?(str)
    # use this method on string representations of dates.  If only one space in the string, then the day is not provided.
    (str.count ' ') == 1
  end

  def protocol_section
    key_check(content['Study']['ProtocolSection'])
  end

  def results_section
    key_check(content['Study']['ResultsSection'])
  end

  def derived_section
    key_check(content['Study']['DerivedSection'])
  end

  def contacts_location_module
    key_check(protocol_section['ContactsLocationsModule'])
  end

  def locations_array
    locations_list = key_check(contacts_location_module['LocationList'])
    locations_list['Location'] || []
  end
  
  def study_data 
    protocol = protocol_section
    status = protocol['StatusModule']
    ident = protocol['IdentificationModule']
    design = key_check(protocol['DesignModule'])
    oversight = key_check(protocol['OversightModule'])
    ipd_sharing = key_check(protocol['IPDSharingStatementModule'])
    study_posted = status['StudyFirstPostDateStruct']
    results_posted = key_check(status['ResultsFirstPostDateStruct'])
    disp_posted = key_check(status['DispFirstPostDateStruct'])
    last_posted = status['LastUpdatePostDateStruct']
    start_date = key_check(status['StartDateStruct'])
    completion_date = key_check(status['CompletionDateStruct'])
    primary_completion_date = key_check(status['PrimaryCompletionDateStruct'])
    results = key_check(content['Study']['ResultsSection'])
    baseline = key_check(results['BaselineCharacteristicsModule'])
    enrollment = key_check(design['EnrollmentInfo'])
    expanded = key_check(design['ExpandedAccessTypes'])
    biospec = key_check(design['BioSpec'])

    { 
      nct_id: nct_id,
      nlm_download_date_description: nil,
      # "DataVrs":"2020:01:05 23:07:51.513"
      study_first_submitted_date: get_date(status['StudyFirstSubmitDate']),
      results_first_submitted_date: get_date(status['ResultsFirstSubmitDate']),
      disposition_first_submitted_date: get_date(status['DispFirstSubmitDate']),
      last_update_submitted_date: get_date(status['LastUpdateSubmitDate']),
      study_first_submitted_qc_date: status['StudyFirstSubmitQCDate'],
      study_first_posted_date: study_posted['StudyFirstPostDate'],
      study_first_posted_date_type: study_posted['StudyFirstPostDateType'],
      results_first_submitted_qc_date: status['ResultsFirstSubmitQCDate'],
      results_first_posted_date: results_posted['ResultsFirstPostDate'],
      results_first_posted_date_type: results_posted['ResultsFirstPostDateType'],
      disposition_first_submitted_qc_date: status['DispFirstSubmitQCDate'],
      disposition_first_posted_date: disp_posted['DispFirstPostDate'],
      disposition_first_posted_date_type: disp_posted['DispFirstPostDateType'],
      last_update_submitted_qc_date: status['LastUpdateSubmitDate'],
      last_update_posted_date: last_posted['LastUpdatePostDate'],
      last_update_posted_date_type: last_posted['LastUpdatePostDateType'],
      start_month_year: start_date['StartDate'],
      start_date_type: start_date['StartDateType'],
      start_date: convert_date(start_date['StartDate']),
      verification_month_year: status['StatusVerifiedDate'],
      verification_date: convert_date(status['StatusVerifiedDate']),
      completion_month_year: completion_date['CompletionDate'],
      completion_date_type: completion_date['CompletionDateType'],
      completion_date: convert_date(completion_date['CompletionDate']),
      primary_completion_month_year: primary_completion_date['PrimaryCompletionDate'],
      primary_completion_date_type: primary_completion_date['PrimaryCompletionDateType'],
      primary_completion_date: convert_date(primary_completion_date['PrimaryCompletionDate']),
      target_duration: design['TargetDuration'],
      study_type: design['StudyType'],
      acronym: ident['Acronym'],
      baseline_population: baseline['BaselinePopulationDescription'],
      brief_title: ident['BriefTitle'],
      official_title: ident['OfficialTitle'],
      overall_status: status['OverallStatus'],
      last_known_status: status['LastKnownStatus'],
      phase: key_check(design['PhaseList'])['Phase'],
      enrollment: enrollment['EnrollmentCount'],
      enrollment_type: enrollment['EnrollmentType'],
      source: nil,
      limitations_and_caveats: key_check(results['MoreInfoModule'])['LimitationsAndCaveats'],
      number_of_arms: nil,
      number_of_groups: nil,
      why_stopped: status['WhyStopped'],
      has_expanded_access: nil,
      expanded_access_type_individual: get_boolean(expanded['ExpAccTypeIndividual']),
      expanded_access_type_intermediate: get_boolean(expanded['ExpAccTypeIntermediate']),
      expanded_access_type_treatment: get_boolean(expanded['ExpAccTypeTreatment']),
      has_dmc: get_boolean(oversight['OversightHasDMC']),
      is_fda_regulated_drug: get_boolean(oversight['IsFDARegulatedDrug']),
      is_fda_regulated_device: get_boolean(oversight['IsFDARegulatedDevice']),
      is_unapproved_device: nil,
      is_ppsd: nil,
      is_us_export: nil,
      biospec_retention: biospec['BioSpecRetention'],
      biospec_description: biospec['BioSpecDescription'],
      ipd_time_frame: ipd_sharing['IPDSharingTimeFrame'],
      ipd_access_criteria: ipd_sharing['IPDSharingAccessCriteria'],
      ipd_url: ipd_sharing['IPDSharingURL'],
      plan_to_share_ipd: ipd_sharing['IPDSharing'],
      plan_to_share_ipd_description: ipd_sharing['IPDSharingDescription']
    }
  end

  def design_groups_data
    arms_intervention = key_check(protocol_section['ArmsInterventionsModule'])
    arms_group_list = key_check(arms_intervention['ArmGroupList'])
    arms_groups = arms_group_list['ArmGroup'] || []
    collection = []
    arms_groups.each do |group|
      collection.push( 
                      design_group: {
                                      nct_id: nct_id,
                                      group_type: group['ArmGroupType'],
                                      title: group['ArmGroupLabel'],
                                      description: group['ArmGroupDescription']
                                    },
                      design_group_interventions: design_group_interventions_data(group)
                      )
    end
    collection
  end

  def design_group_interventions_data(arms_group)
    collection = []
    intervention_list = key_check(arms_group['ArmGroupInterventionList'])
    intervention_names = intervention_list['ArmGroupInterventionName'] || []
    intervention_names.each do |name|
      # I collect the info I need to do queries later so I can create or find the links
      # between design groups and interventions in the database
      divide = name.split(': ')
      collection.push(
                      nct_id: nct_id,
                      name: divide[1],
                      type: divide[0],
                      design_group: arms_group['ArmGroupLabel']
                    )
    end
    collection
    # nct_id: string, design_group_id: integer, intervention_id: integer
  end

  def interventions_data
    arms_intervention = key_check(protocol_section['ArmsInterventionsModule'])
    intervention_list = key_check(arms_intervention['InterventionList'])
    interventions = intervention_list['Intervention'] || []
    collection = []
    interventions.each do |intervention|
      collection.push(
                      intervention: {
                                      nct_id: nct_id,
                                      intervention_type: intervention['InterventionType'],
                                      name: intervention['InterventionName'],
                                      description: intervention['InterventionDescription']
                                    },
                      intervention_other_names: intervention_other_names_data(intervention)
                    )
    end
    collection
  end

  def intervention_other_names_data(intervention)
    other_name_list = key_check(intervention['InterventionOtherNameList'])
    collection = []
    other_names = other_name_list['InterventionOtherName'] || []
    other_names.each do |name|
      collection.push(nct_id: nct_id, intervention_id: nil, name: name)
    end
    collection
  end

  def detailed_description_data
    protocol = protocol_section 
    { nct_id: nct_id, description: key_check(protocol['DescriptionModule'])['DetailedDescription'] }
  end

  def brief_summary_data
    protocol = protocol_section
    { nct_id: nct_id, description: key_check(protocol['DescriptionModule'])['BriefSummary'] }
  end

  def self.make_list(array)
    array.join(', ')
  end

  def designs_data 
    protocol = protocol_section
    design = key_check(protocol['DesignModule'])
    info = key_check(design['DesignInfo'])
    masking = key_check(info['DesignMaskingInfo'])
    masked_list = key_check(masking['DesignWhoMaskedList'])
    who_masked = masked_list['DesignWhoMasked'] || []
    observation_list = key_check(info['DesignObservationalModelList'])
    observations = observation_list['DesignObservationalModel'] || []
    time_perspective_list = key_check(info['DesignTimePerspectiveList'])
    time_perspectives = time_perspective_list['DesignTimePerspective'] || []
    {
      nct_id: nct_id,
      allocation: info['DesignAllocation'],
      observational_model: StudyJsonRecord.make_list(observations),
      intervention_model: info['DesignInterventionModel'],
      intervention_model_description: info['DesignInterventionModelDescription'],
      primary_purpose: info['DesignPrimaryPurpose'],
      time_perspective: StudyJsonRecord.make_list(time_perspectives),
      masking: masking['DesignMasking'],
      masking_description: masking['DesignMaskingDescription'],
      subject_masked: is_masked?(who_masked, ['Subject','Participant']),
      caregiver_masked: is_masked?(who_masked, ['Caregiver','Care Provider']),
      investigator_masked: is_masked?(who_masked, ['Investigator']),
      outcomes_assessor_masked: is_masked?(who_masked, ['Outcomes Assessor']),
    }
  end

  def is_masked?(who_masked_array, query_array)
     # example who_masked array ["Participant", "Care Provider", "Investigator", "Outcomes Assessor"]
    query_array.each do |term|
      return true if who_masked_array.try(:include?, term)
    end
    nil
  end

  def eligibility_data
    protocol = protocol_section
    eligibility =  key_check(protocol['EligibilityModule'])
    {
      nct_id: nct_id,
      sampling_method: eligibility['SamplingMethod'],
      population: eligibility['StudyPopulation'],
      maximum_age: eligibility['MaximumAge'] || 'N/A',
      minimum_age: eligibility['MinimumAge'] || 'N/A',
      gender: eligibility['Gender'],
      gender_based: get_boolean(eligibility['GenderBased']),
      gender_description: eligibility['GenderDescription'],
      healthy_volunteers: eligibility['HealthyVolunteers'],
      criteria: eligibility['EligibilityCriteria']
    }
  end

  def participant_flow_data
    results = key_check(results_section)
    participant_flow = key_check(results['ParticipantFlowModule'])
    {
      nct_id: nct_id,
      recruitment_details: participant_flow['FlowRecruitmentDetails'],
      pre_assignment_details: participant_flow['FlowPreAssignmentDetails'],
    }
  end

  def baseline_measurements_data
    results = results_section
    baseline_characteristics_module = key_check(results['BaselineCharacteristicsModule'])
    baseline_measure_list = key_check(baseline_characteristics_module['BaselineMeasureList'])
    baseline_measure = baseline_measure_list['BaselineMeasure'] || []
    collection = {result_groups: baseline_result_groups_data, baseline_counts: baseline_counts_data, measurements: []}
    baseline_measure.each do |measure|
      baseline_class_list = key_check(measure['BaselineClassList'])
      baseline_classes = baseline_class_list['BaselineClass'] || []
      baseline_classes.each do |baseline_class|
        baseline_category_list = key_check(baseline_class['BaselineCategoryList'])
        baseline_categories = baseline_category_list['BaselineCategory'] || []
        baseline_categories.each do |baseline_category|
          measurement_list = key_check(baseline_category['BaselineMeasurementList'])
          measurements = measurement_list['BaselineMeasurement'] || []
          measurements.each do |measurement|
            param_value = measurement['BaselineMeasurementValue']
            dispersion_value = measurement['BaselineMeasurementSpread']
            collection[:measurements].push(
                                            nct_id: nct_id,
                                            result_group_id: nil,
                                            ctgov_group_code: measurement['BaselineMeasurementGroupId'],
                                            classification: baseline_class['BaselineClassTitle'],
                                            category: baseline_category['BaselineCategoryTitle'],
                                            title: measure['BaselineMeasureTitle'],
                                            description: measure['BaselineMeasureDescription'],
                                            units: measure['BaselineMeasureUnitOfMeasure'],
                                            param_type: measure['BaselineMeasureParamType'],
                                            param_value: param_value,
                                            param_value_num: StudyJsonRecord.float(param_value),
                                            dispersion_type: measure['BaselineMeasureDispersionType'],
                                            dispersion_value: dispersion_value,
                                            dispersion_value_num: StudyJsonRecord.float(dispersion_value),
                                            dispersion_lower_limit: nil,
                                            dispersion_upper_limit: nil,
                                            explanation_of_na: measurement['BaselineMeasurementComment']
                                          )
          end
        end
      end
    end
    collection
  end

  def self.float(string)
    Float(string) rescue nil
  end

  def baseline_result_groups_data
    results = results_section
    baseline_characteristics_module = key_check(results['BaselineCharacteristicsModule'])
    baseline_group_list = key_check(baseline_characteristics_module['BaselineGroupList'])
    baseline_group = baseline_group_list['BaselineGroup'] || []
    collection = []
    baseline_group.each do |group|
      collection.push(
                        nct_id: nct_id,
                        ctgov_group_code: group['BaselineGroupId'],
                        result_type: 'Baseline',
                        title: group['BaselineGroupTitle'],
                        description: group['BaselineGroupDescription']
                      )
    end
    collection
  end

  def baseline_counts_data
    results = results_section
    baseline_characteristics_module = key_check(results['BaselineCharacteristicsModule'])
    baseline_denom_list = key_check(baseline_characteristics_module['BaselineDenomList'])
    baseline_denom = key_check(baseline_denom_list['BaselineDenom'])
    collection = []
    baseline_denom.each do |denom|
      baseline_denom_count_list = denom['BaselineDenomCountList']
      baseline_denom_count = baseline_denom_count_list['BaselineDenomCount'] || []
      baseline_denom_count.each do |count|
        collection.push(
                          nct_id: nct_id,
                          result_group_id: nil,
                          ctgov_group_code: count['BaselineDenomCountGroupId'],
                          units: denom['BaselineDenomUnits'],
                          scope: 'overall',
                          count: count['BaselineDenomCountValue']

                        )
      end
    end
    collection
  end

  def browse_conditions_data
    browse('Condition')
  end

  def browse_interventions_data
    browse('Intervention')
  end

  def browse(type='Condition')
    derived = derived_section
    browse_module = key_check(derived["#{type}BrowseModule"])
    mesh_list = key_check(browse_module["#{type}MeshList"])
    meshes = mesh_list["#{type}Mesh"] || []
    collection = []
    meshes.each do |mesh|
      collection.push(
                        nct_id: nct_id, mesh_term: mesh["#{type}MeshTerm"], downcase_mesh_term: mesh["#{type}MeshTerm"].try(:downcase)

                      )
    end
    collection
  end

  def central_contacts_data
    central_contacts_list = key_check(contacts_location_module['CentralContactList'])
    central_contacts = central_contacts_list['CentralContact'] || []
    collection = []

    central_contacts.each do |contact|
      collection.push(
                        nct_id: nct_id,
                        contact_type: nil,
                        contact_role: contact['CentralContactRole'],
                        name: contact['CentralContactName'],
                        phone: contact['CentralContactPhone'],
                        email: contact['CentralContactEMail']
                      )
    end
    collection
  end

  def conditions_data
    conditions_module = key_check(protocol_section['ConditionsModule'])
    conditions_list = key_check(conditions_module['ConditionList'])
    conditions = conditions_list['Condition'] || []
    collection = []
    conditions.each do |condition|
      collection.push(nct_id: nct_id, name: condition, downcase_name: condition.try(:downcase))
    end
    {nct_id: nil, name: nil, downcase_name: nil}
    collection
  end

  def countries_data
    misc_module = key_check(derived_section['MiscInfoModule'])
    removed_country_list = key_check(misc_module['RemovedCountryList'])
    removed_countries = removed_country_list['RemovedCountry'] || []
    collection = []

    locations_array.each do |location|
      collection.push(nct_id: nct_id, name: location['LocationCountry'], removed: false)
    end

    removed_countries.each do |country|
      collection.push(nct_id: nct_id, name: country, removed: true)
    end
    collection
  end

  def documents_data
    reference_module = key_check(protocol_section['ReferencesModule'])
    avail_ipd_list = key_check(reference_module['AvailIPDList'])
    avail_ipd = avail_ipd_list['AvailIPD'] || []
    collection = []

    avail_ipd.each do |item|
      collection.push(
                        nct_id: nct_id,
                        document_id: item['AvailIPDId'],
                        document_type: item['AvailIPDType'],
                        url: item['AvailIPDURL'],
                        comment: item['AvailIPDComment']
                      )
    end
    collection
  end

  def facilities_data
    collection = []
    locations_array.each do |location|
      location_contact_list = key_check(location['LocationContactList'])
      location_contact = location_contact_list['LocationContact'] || []
      facility_contacts = []
      facility_investigators = []
      location_contact.each do |contact|
        contact_role = contact['LocationContactRole']
        if contact_role =~ /Investigator/i
          facility_investigators.push(
                                      nct_id: nct_id,
                                      facility_id: nil,
                                      role: contact_role,
                                      name: contact['LocationContactName']
                                    )
        else
          facility_contacts.push(
                                  nct_id: nct_id,
                                  facility_id: nil,
                                  contact_type: nil,
                                  contact_role: contact_role,
                                  name: contact['LocationContactName'],
                                  email: contact['LocationContactEMail'],
                                  phone: contact['LocationContactPhone']
                                )
        end
      end

      collection.push(
                      nct_id: nct_id,
                      status: location['LocationStatus'],
                      name: location['LocationFacility'],
                      city: location['LocationCity'],
                      state: location['LocationState'],
                      zip: location['LocationZip'],
                      country: location['LocationCountry'],
                      facility_contacts: facility_contacts,
                      facility_investigators: facility_investigators
                    )
    end
    collection
  end

  def id_information_data
    identification_module = key_check(protocol_section['IdentificationModule'])
    org_study_info = key_check(identification_module['OrgStudyIdInfo'])
    secondary_info_list = key_check(identification_module['SecondaryIdInfoList'])
    secondary_info = secondary_info_list['SecondaryIdInfo'] || []
    collection = [{nct_id: nct_id, id_type: 'org_study_id', id_value: org_study_info['OrgStudyId']}]
    
    secondary_info.each do |info|
      collection.push(
        nct_id: nct_id, id_type: 'secondary_id', id_value: info['SecondaryId']
      )
    end
    collection
  end

  def ipd_information_types_data
    ipd_sharing_statement_module = key_check(protocol_section['IPDSharingStatementModule'])
    ipd_sharing_info_type_list = key_check(ipd_sharing_statement_module['IPDSharingInfoTypeList'])
    ipd_sharing_info_type = ipd_sharing_info_type_list['IPDSharingInfoType'] || []
    collection = []

    ipd_sharing_info_type.each do |info|
      collection.push(nct_id: nct_id, name: info)
    end

    collection
  end

  def keywords_data
    conditions_module = key_check(protocol_section['ConditionsModule'])
    keyword_list = key_check(conditions_module['KeywordList'])
    keywords = keyword_list['Keyword'] || []
    collection = []

    keywords.each do |keyword|
      collection.push(nct_id: nct_id, name: keyword, downcase_name: keyword.downcase)
    end
    collection
  end

  def links_data
    references_module = key_check(protocol_section['ReferencesModule'])
    see_also_link_list = key_check(references_module['SeeAlsoLinkList'])
    see_also_links = see_also_link_list['SeeAlsoLink'] || []
    collection = []

    see_also_links.each do |link|
      collection.push(nct_id: nct_id, url: link['SeeAlsoLinkURL'], description: link['SeeAlsoLinkLabel'])
    end
    collection
  end

  def self.new_check
    nct = %w[
      NCT01122706
      NCT01122745
      NCT04213846
      NCT04214080
      NCT04214093
      NCT00444327
      NCT00444431
      NCT00444600
      NCT04213976
      NCT04213794
      NCT04164186
      NCT04210765
      NCT04175600
      NCT04158700
      NCT01301274
      NCT01301287
      NCT01301261
      NCT03894189
    ]
    
    # StudyJsonRecord.where(nct_id: nct).each{ |i| puts i.links_data }
    StudyJsonRecord.all.order(:id).each{ |i| puts i.links_data }
    # StudyJsonRecord.where(nct_id: nct).each{ |i| puts i.data_collection }
    # StudyJsonRecord.all.order(:id).each{ |i| puts i.data_collection }
    []
  end

  def data_collection
    puts "Json Record #{id}"
    {
      study: study_data,
      design_groups: design_groups_data,
      interventions: interventions_data,
      detailed_description: detailed_description_data,
      brief_summary: brief_summary_data,
      design: designs_data,
      eligibility: eligibility_data,
      participant_flow: participant_flow_data,
      baseline_measurements: baseline_measurements_data,
      browse_conditions: browse_conditions_data,
      browse_interventions: browse_interventions_data,
      central_contacts_list: central_contacts_data,
      conditions: conditions_data,
      countries: countries_data,
      documents: documents_data,
      facilities: facilities_data,
      id_information: id_information_data,
      ipd_information_type: ipd_information_types_data,
      keywords: keywords_data
    }
  end
 

  #   Link.create_all_from(opts)
  #   Milestone.create_all_from(opts)
  #   Outcome.create_all_from(opts)
  #   OverallOfficial.create_all_from(opts)
  #   DesignOutcome.create_all_from(opts)
  #   PendingResult.create_all_from(opts)
  #   ProvidedDocument.create_all_from(opts)
  #   ReportedEvent.create_all_from(opts)
  #   ResponsibleParty.create_all_from(opts)
  #   ResultAgreement.create_all_from(opts)
  #   ResultContact.create_all_from(opts)
  #   Reference.create_all_from(opts)
  #   Sponsor.create_all_from(opts)

end
