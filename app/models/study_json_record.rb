require 'open-uri'
require 'fileutils'
# require 'zip'
# run incremental load with: bundle exec rake db:load[1,incremental,true,ctgov_beta]
# run full load with: bundle exec rake db:load[1,full,true,ctgov_beta]
include ActionView::Helpers::DateHelper
class StudyJsonRecord < ActiveRecord::Base
  self.table_name = 'ctgov_beta.study_json_records'
  def self.run(params={})
    Util::DbManager.new(params).public_con
    @full_featured = params[:full_featured] || false
    @params = params
    @type = params[:event_type] ? params[:event_type] : 'incremental'
    @days_back = (params[:days_back] ? params[:days_back] : 2)
    puts 'params set...'
    print 'now running'
    begin
     @type == 'full' ? full : incremental
    rescue => error
      msg="#{error.message} (#{error.class} #{error.backtrace}"
      puts"#{@type} load failed in run: #{msg}"
    end
  end

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

  def self.full
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

  def self.incremental
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
    
    # for x in 1..limit
    for x in 1..2
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
      #   "https://clinicaltrials.gov/api/query/full_studies?expr=AREA[LastUpdatePostDate]RANGE[01/01/2020,%20MAX]&fmt=json"
      url = "https://clinicaltrials.gov/api/query/full_studies?expr=#{time_range}&min_rnk=#{min}&max_rnk=#{max}&fmt=json"
      data = json_data(url)['FullStudiesResponse']['FullStudies']
      save_study_records(data)
    rescue
      retry if (retries += 1) < 6
    end
  end

  def self.save_study_records(study_batch)
    return unless study_batch

    StudyJsonRecord.set_table_schema('ctgov_beta')
    nct_id_array = study_batch.map{|study_data| study_data['Study']['ProtocolSection']['IdentificationModule']['NCTId'] }
    clear_out_data_for(nct_id_array)

    study_batch.each do |study_data|
      save_single_study(study_data)
    end
  end

  def self.save_single_study(study_data)
    nct_id = study_data['Study']['ProtocolSection']['IdentificationModule']['NCTId']
    record = StudyJsonRecord.find_by(nct_id: nct_id) || StudyJsonRecord.new(nct_id: nct_id)
    record.content = study_data
    record.saved_study_at = nil
    record.download_date = Time.current
    if record.save
      record.build_study
    else
      puts "failed to save #{nct_id}"
    end
  end

  def self.clear_out_data_for(nct_ids)
    ids=nct_ids.map { |i| "'" + i.to_s + "'" }.join(",")
    names = Util::DbManager.new.loadable_tables
    names.each { |table|
      stime=Time.zone.now
      ActiveRecord::Base.connection.execute("DELETE FROM ctgov_beta.#{table} WHERE nct_id IN (#{ids})")
      puts "deleted studies from #{table}   #{Time.zone.now - stime}"
    }
    delete_json_records(ids)
    puts object_counts
  end

  def self.delete_json_records(ids)
    ActiveRecord::Base.connection.execute("DELETE FROM #{self.table_name} WHERE nct_id IN (#{ids})")
  end

  def self.json_data(url="https://clinicaltrials.gov/api/query/full_studies?expr=#{time_range}&min_rnk=1&max_rnk=100&fmt=json")
    puts url
    page = open(url)
    JSON.parse(page.read)
  end

  def self.time_range
    return nil if @type == 'full'
    return nil unless @days_back != 'nil'

    date = (Date.current - @days_back.to_i).strftime('%m/%d/%Y')
    "AREA[LastUpdatePostDate]RANGE[#{date},%20MAX]"
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

  def annotation_section
    key_check(content['Study']['AnnotationSection'])
  end

  def document_section
    key_check(content['Study']['DocumentSection'])
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
    return nil if protocol.empty?

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
    expanded_access = status.dig('ExpandedAccessInfo', 'HasExpandedAccess')
    expanded = key_check(design['ExpandedAccessTypes'])
    biospec = key_check(design['BioSpec'])
    arms_intervention = key_check(protocol['ArmsInterventionsModule'])
    arms_group_list = key_check(arms_intervention['ArmGroupList'])
    arms_groups = arms_group_list['ArmGroup'] || []

    { 
      nct_id: nct_id,
      nlm_download_date_description: download_date,
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
      source: ident.dig('Organization', 'OrgFullName'),
      limitations_and_caveats: key_check(results['MoreInfoModule'])['LimitationsAndCaveats'],
      number_of_arms: arms_groups.count,
      number_of_groups: arms_groups.count,
      why_stopped: status['WhyStopped'],
      has_expanded_access: get_boolean(expanded_access),
      expanded_access_type_individual: get_boolean(expanded['ExpAccTypeIndividual']),
      expanded_access_type_intermediate: get_boolean(expanded['ExpAccTypeIntermediate']),
      expanded_access_type_treatment: get_boolean(expanded['ExpAccTypeTreatment']),
      has_dmc: get_boolean(oversight['OversightHasDMC']),
      is_fda_regulated_drug: get_boolean(oversight['IsFDARegulatedDrug']),
      is_fda_regulated_device: get_boolean(oversight['IsFDARegulatedDevice']),
      is_unapproved_device: get_boolean(oversight['IsUnapprovedDevice']),
      is_ppsd: get_boolean(oversight['IsPPSD']),
      is_us_export: get_boolean(oversight['IsUSExport']),
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
    return nil if arms_groups.empty?

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
    return nil if intervention_names.empty?

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
  end

  def interventions_data
    arms_intervention = key_check(protocol_section['ArmsInterventionsModule'])
    intervention_list = key_check(arms_intervention['InterventionList'])
    interventions = intervention_list['Intervention'] || []
    collection = []
    return nil if interventions.empty?

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
    return nil if other_names.empty?

    other_names.each do |name|
      collection.push(nct_id: nct_id, intervention_id: nil, name: name)
    end
    collection
  end

  def detailed_description_data
    protocol = protocol_section 
    description = key_check(protocol['DescriptionModule'])['DetailedDescription']
    return nil unless description
    { nct_id: nct_id, description: description }
  end

  def brief_summary_data
    protocol = protocol_section
    description = key_check(protocol['DescriptionModule'])['BriefSummary']
    return nil unless description

    { nct_id: nct_id, description: description }
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
    return nil if info.empty?

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
    return nil if eligibility.empty?

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
    return nil if participant_flow.empty?

    {
      nct_id: nct_id,
      recruitment_details: participant_flow['FlowRecruitmentDetails'],
      pre_assignment_details: participant_flow['FlowPreAssignmentDetails'],
    }
  end

  def baseline_measurements_data
    results = results_section
    baseline_characteristics_module = key_check(results['BaselineCharacteristicsModule'])
    return nil if baseline_characteristics_module.empty?

    baseline_measure_list = key_check(baseline_characteristics_module['BaselineMeasureList'])
    baseline_measures = baseline_measure_list['BaselineMeasure'] || []
    collection = {result_groups: baseline_result_groups_data, baseline_counts: baseline_counts_data, measurements: []}
    return if baseline_measures.empty?

    baseline_measures.each do |measure|
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
                                            dispersion_lower_limit: StudyJsonRecord.float(measurement['BaselineMeasurementLowerLimit']),
                                            dispersion_upper_limit: StudyJsonRecord.float(measurement['BaselineMeasurementUpperLimit']),
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
    StudyJsonRecord.result_groups(baseline_group, 'Baseline', 'Baseline', nct_id)
  end

  def baseline_counts_data
    results = results_section
    baseline_characteristics_module = key_check(results['BaselineCharacteristicsModule'])
    baseline_denom_list = key_check(baseline_characteristics_module['BaselineDenomList'])
    baseline_denoms = key_check(baseline_denom_list['BaselineDenom'])
    collection = []
    return nil if baseline_demons.empty?

    baseline_denoms.each do |denom|
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
    return nil if meshes.empty?

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
    return nil if central_contacts.empty?
    
    central_contacts.each_with_index do |contact, index|
      collection.push(
                        nct_id: nct_id,
                        contact_type: index == 0 ? 'primary' : 'backup',
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
    return nil if conditions.empty?

    conditions.each do |condition|
      collection.push(nct_id: nct_id, name: condition, downcase_name: condition.try(:downcase))
    end
    collection
  end

  def countries_data
    misc_module = key_check(derived_section['MiscInfoModule'])
    removed_country_list = key_check(misc_module['RemovedCountryList'])
    removed_countries = removed_country_list['RemovedCountry'] || []
    collection = []
    return nil unless !locations_array.empty? || !removed_countries.empty?

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
    avail_ipds = avail_ipd_list['AvailIPD'] || []
    collection = []
    return nil if avail_ipds.empty?

    avail_ipds.each do |item|
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
    return nil if locations_array.empty?

    locations_array.each do |location|
      location_contact_list = key_check(location['LocationContactList'])
      location_contact = location_contact_list['LocationContact'] || []
      facility_contacts = []
      facility_investigators = []
      location_contact.each_with_index do |contact, index|
        contact_role = contact['LocationContactRole']
        if contact_role =~ /Investigator|Study Chair/i
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
                                  contact_type: index == 0 ? 'primary' : 'backup',
                                  name: contact['LocationContactName'],
                                  email: contact['LocationContactEMail'],
                                  phone: contact['LocationContactPhone']
                                )
        end
      end

      collection.push(
                      facility: {
                                    nct_id: nct_id,
                                    status: location['LocationStatus'],
                                    name: location['LocationFacility'],
                                    city: location['LocationCity'],
                                    state: location['LocationState'],
                                    zip: location['LocationZip'],
                                    country: location['LocationCountry']
                                  },
                      facility_contacts: facility_contacts,
                      facility_investigators: facility_investigators
                    )
    end
    collection
  end

  def id_information_data
    identification_module = key_check(protocol_section['IdentificationModule'])
    alias_list = key_check(identification_module['NCTIdAliasList'])
    nct_id_alias = alias_list['NCTIdAlias'] || []
    org_study_info = key_check(identification_module['OrgStudyIdInfo'])
    secondary_info_list = key_check(identification_module['SecondaryIdInfoList'])
    secondary_info = secondary_info_list['SecondaryIdInfo'] || []
    return if org_study_info.empty? && secondary_info.empty? && nct_id_alias.empty?

    collection = [{nct_id: nct_id, id_type: 'org_study_id', id_value: org_study_info['OrgStudyId']}]
    

    nct_id_alias.each do |nct_alias|
      collection.push(
        nct_id: nct_id, id_type: 'nct_alias', id_value: nct_alias
      )
    end
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
    ipd_sharing_info_types = ipd_sharing_info_type_list['IPDSharingInfoType'] || []
    collection = []
    return nil if ipd_sharing_info_types.empty?

    ipd_sharing_info_types.each do |info|
      collection.push(nct_id: nct_id, name: info)
    end

    collection
  end

  def keywords_data
    conditions_module = key_check(protocol_section['ConditionsModule'])
    keyword_list = key_check(conditions_module['KeywordList'])
    keywords = keyword_list['Keyword'] || []
    collection = []
    return nil if keywords.empty?

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
    return nil if see_also_links.empty?

    see_also_links.each do |link|
      collection.push(nct_id: nct_id, url: link['SeeAlsoLinkURL'], description: link['SeeAlsoLinkLabel'])
    end
    collection
  end

  def milestones_data
    participant_flow_module = key_check(results_section['ParticipantFlowModule'])
    flow_period_list = key_check(participant_flow_module['FlowPeriodList'])
    flow_periods = flow_period_list['FlowPeriod'] || []
    collection = {result_groups: flow_result_groups_data, milestones: []}
    return nil if flow_periods.empty?

    flow_periods.each do |period|

      flow_period = period['FlowPeriodTitle']
      flow_milestone_list = key_check(period['FlowMilestoneList'])
      flow_milestones = flow_milestone_list['FlowMilestone'] || []

      flow_milestones.each do |milestone|
        flow_achievement_list = key_check(milestone['FlowAchievementList'])
        flow_achievements = flow_achievement_list['FlowAchievement'] || []

        flow_achievements.each do |achievement|
          collection[:milestones].push(
                          nct_id: nct_id,
                          result_group_id: nil,
                          ctgov_group_code: achievement['FlowAchievementGroupId'],
                          title: milestone['FlowMilestoneType'],
                          period: period['FlowPeriodTitle'],
                          description: achievement['FlowAchievementComment'],
                          count: achievement['FlowAchievementNumSubjects']
                          )
        end
      end
    end
    return nil if collection[:milestones].empty?

    collection
  end

  def flow_result_groups_data
    participant_flow_module = key_check(results_section['ParticipantFlowModule'])
    flow_group_list = key_check(participant_flow_module['FlowGroupList'])
    flow_groups = flow_group_list['FlowGroup'] || []
    StudyJsonRecord.result_groups(flow_groups, 'Flow', 'Participant Flow', nct_id)
  end

  def outcomes_data
    outcomes_module = key_check(results_section['OutcomeMeasuresModule'])
    outcome_measure_list = key_check(outcomes_module['OutcomeMeasureList'])
    outcome_measures = outcome_measure_list['OutcomeMeasure'] || []
    collection = {result_groups: outcome_result_groups_data, outcome_measures: []}
    return nil if outcome_measures.empty?

    outcome_measures.each do |outcome_measure|
      collection[:outcome_measures].push(
                      outcome_measure: {
                                        nct_id: nct_id,
                                        outcome_type: outcome_measure['OutcomeMeasureType'],
                                        title: outcome_measure['OutcomeMeasureTitle'],
                                        description: outcome_measure['OutcomeMeasureDescription'],
                                        time_frame: outcome_measure['OutcomeMeasureTimeFrame'],
                                        population: outcome_measure['OutcomeMeasurePopulationDescription'],
                                        anticipated_posting_date: convert_date(outcome_measure['OutcomeMeasureAnticipatedPostingDate']),
                                        anticipated_posting_month_year: outcome_measure['OutcomeMeasureAnticipatedPostingDate'],
                                        units: outcome_measure['OutcomeMeasureUnitOfMeasure'],
                                        units_analyzed: outcome_measure['OutcomeMeasureTypeUnitsAnalyzed'],
                                        dispersion_type: outcome_measure['OutcomeMeasureDispersionType'],
                                        param_type: outcome_measure['OutcomeMeasureParamType']
                                        },
                      outcome_counts: outcome_counts_data(outcome_measure),
                      outcome_measurements: outcome_measurements_data(outcome_measure),
                      outcome_analyses: outcome_analyses_data(outcome_measure)
                      )
    end
    collection
  end

  def outcome_result_groups_data
    outcomes_module = key_check(results_section['OutcomeMeasuresModule'])
    outcome_measure_list = key_check(outcomes_module['OutcomeMeasureList'])
    outcome_measures = outcome_measure_list['OutcomeMeasure'] || []
    collection = []

    outcome_measures.each do |measure|
      outcome_group_list = key_check(measure['OutcomeGroupList'])
      outcome_groups = outcome_group_list['OutcomeGroup'] || []
      collection.push(
                      StudyJsonRecord.result_groups(outcome_groups, 'Outcome', 'Outcome', nct_id)
                      )
    end
    collection.flatten.uniq
  end

  def self.result_groups(groups, key_name='Flow', type='Participant Flow', nct_id)
    collection = []
    return nil if  groups.nil? || groups.empty?

    groups.each do |group|
      collection.push(
                        nct_id: nct_id,
                        ctgov_group_code: group["#{key_name}GroupId"],
                        result_type: type,
                        title: group["#{key_name}GroupTitle"],
                        description: group["#{key_name}GroupDescription"]
                      )
    end
    collection
  end

  def outcome_counts_data(outcome_measure)
    outcome_denom_list = key_check(outcome_measure['OutcomeDenomList'])
    outcome_denoms = outcome_denom_list['OutcomeDenom'] || []
    collection = []
    return nil if outcome_denoms.empty?

    outcome_denoms.each do |denom|
      outcome_denom_count_list = key_check(denom['OutcomeDenomCountList'])
      outcome_denom_count = outcome_denom_count_list['OutcomeDenomCount'] || []

      outcome_denom_count.each do |denom_count|
        collection.push(
                        nct_id: nct_id,
                        outcome_id: nil,
                        result_group_id: nil,
                        ctgov_group_code: denom_count['OutcomeDenomCountGroupId'],
                        scope: 'Measure',
                        units: denom['OutcomeDenomUnits'],
                        count: denom_count['OutcomeDenomCountValue']
                        )
      end
    end
    collection
  end

  def outcome_measurements_data(outcome_measure)
    outcome_class_list = key_check(outcome_measure['OutcomeClassList'])
    outcome_classes = outcome_class_list['OutcomeClass'] || []
    collection = []
    return nil if outcome_classes.empty?

    outcome_classes.each do |outcome_class|
    outcome_category_list = key_check(outcome_class['OutcomeCategoryList'])
    outcome_categories = outcome_category_list['OutcomeCategory'] || []

      outcome_categories.each do |category|
        outcome_measurement_list = key_check(category['OutcomeMeasurementList'])
        measurements = outcome_measurement_list['OutcomeMeasurement'] || []

        measurements.each do |measure|
            collection.push(
                            nct_id: nct_id,
                            outcome_id: nil,
                            result_group_id: nil,
                            ctgov_group_code: measure['OutcomeMeasurementGroupId'],
                            classification: outcome_class['OutcomeClassTitle'],
                            category: category['OutcomeCategoryTitle'],
                            title: outcome_measure['OutcomeMeasureTitle'],
                            description: outcome_measure['OutcomeMeasureDescription'],
                            units: outcome_measure['OutcomeMeasureUnitOfMeasure'],
                            param_type: outcome_measure['OutcomeMeasureParamType'],
                            param_value: measure['OutcomeMeasurementValue'],
                            param_value_num: StudyJsonRecord.float(measure['OutcomeMeasurementValue']),
                            dispersion_type: outcome_measure['OutcomeMeasureDispersionType'],
                            dispersion_value: measure['OutcomeMeasurementSpread'],
                            dispersion_value_num: StudyJsonRecord.float(measure['OutcomeMeasurementSpread']),
                            dispersion_lower_limit: StudyJsonRecord.float(measure['OutcomeMeasurementLowerLimit']),
                            dispersion_upper_limit: StudyJsonRecord.float(measure['OutcomeMeasurementUpperLimit']),
                            explanation_of_na: measure['OutcomeMeasurementComment']
                          )
        end
      end
    end
    collection
  end

  def outcome_analyses_data(outcome_measure)
    outcome_analysis_list = key_check(outcome_measure['OutcomeAnalysisList'])
    outcome_analyses = outcome_analysis_list['OutcomeAnalysis'] || []
    collection = []
    return nil if outcome_analyses.empty?

    outcome_analyses.each do |analysis|
      raw_value = analysis['OutcomeAnalysisPValue'] || ''
      collection.push( 
                      outcome_analysis: {
                                          nct_id: nct_id,
                                          outcome_id: nil,
                                          non_inferiority_type: analysis['OutcomeAnalysisNonInferiorityType'],
                                          non_inferiority_description: analysis['OutcomeAnalysisNonInferiorityComment'],
                                          param_type: analysis['OutcomeAnalysisParamType'],
                                          param_value: analysis['OutcomeAnalysisParamValue'],
                                          dispersion_type: analysis['OutcomeAnalysisDispersionType'],
                                          dispersion_value: analysis['OutcomeAnalysisDispersionValue'],
                                          p_value_modifier: raw_value.gsub(/\d+/, "").gsub('.','').gsub('-','').strip,
                                          p_value: raw_value.gsub(/</, '').gsub(/>/, '').gsub(/ /, '').strip,
                                          p_value_description: analysis['OutcomeAnalysisPValueComment'],
                                          ci_n_sides: analysis['OutcomeAnalysisCINumSides'],
                                          ci_percent: StudyJsonRecord.float(analysis['OutcomeAnalysisCIPctValue']),
                                          ci_lower_limit: analysis['OutcomeAnalysisCILowerLimit'],
                                          ci_upper_limit: analysis['OutcomeAnalysisCIUpperLimit'],
                                          ci_upper_limit_na_comment: analysis['OutcomeAnalysisCIUpperLimitComment'],
                                          
                                          method: analysis['OutcomeAnalysisStatisticalMethod'],
                                          method_description: analysis['OutcomeAnalysisStatisticalComment'],
                                          estimate_description: analysis['OutcomeAnalysisEstimateComment'],
                                          groups_description: analysis['OutcomeAnalysisGroupDescription'],
                                          other_analysis_description: analysis['OutcomeAnalysisOtherAnalysisDescription']
                                        },
                      outcome_analysis_group_ids: outcome_analysis_groups_data(analysis)  
                    )
    end
    collection
  end

  def outcome_analysis_groups_data(outcome_analysis)
    outcome_analysis_group_id_list = key_check(outcome_analysis['OutcomeAnalysisGroupIdList'])
    outcome_analysis_group_ids = outcome_analysis_group_id_list['OutcomeAnalysisGroupId'] || []
    collection = []
    return nil if outcome_analysis_group_ids.empty?
  
    outcome_analysis_group_ids.each do |group_id|
      collection.push(
                      nct_id: nct_id,
                      outcome_analysis_id: nil,
                      result_group_id: nil,
                      ctgov_group_code: group_id
                    )
    end
  end

  def overall_officials_data
    overall_officials_list = key_check(contacts_location_module['OverallOfficialList'])
    overall_officials = overall_officials_list['OverallOfficial'] || []
    collection = []
    return nil if overall_officials.empty?

    overall_officials.each do |overall_official|
      collection.push(
                      nct_id: nct_id,
                      role: overall_official['OverallOfficialRole'],
                      name: overall_official['OverallOfficialName'],
                      affiliation: overall_official['OverallOfficialAffiliation']
                      )
    end
    collection
  end

  def design_outcomes_data
    primary_outcomes = outcome_list('Primary')
    secondary_outcomes = outcome_list('Secondary')
    other_outcomes = outcome_list('Other')
    primary_outcomes ||= []
    secondary_outcomes ||= []
    total = primary_outcomes + secondary_outcomes
    return nil if total.empty?

    total
  end

  def outcome_list(outcome_type='Primary')
    outcomes_module = key_check(protocol_section['OutcomesModule'])
    outcome_list = key_check(outcomes_module["#{outcome_type}OutcomeList"])
    outcomes = outcome_list["#{outcome_type}Outcome"] || []
    collection = []
    return nil if outcomes.empty?

    outcomes.each do |outcome|
      collection.push(
                      nct_id: nct_id,
                      outcome_type: outcome_type.downcase,
                      measure: outcome["#{outcome_type}OutcomeMeasure"],
                      time_frame: outcome["#{outcome_type}OutcomeTimeFrame"],
                      population: nil,
                      description: outcome["#{outcome_type}OutcomeDescription"]
                      )
    end
    collection
  end

  def pending_results_data
    annotation_module = key_check(annotation_section['AnnotationModule'])
    unposted_annotation = key_check(annotation_module['UnpostedAnnotation'])
    unposted_event_list = key_check(unposted_annotation['UnpostedEventList'])
    unposted_events = unposted_event_list['UnpostedEvent'] || []
    collection = []
    return nil if unposted_events.empty?

    unposted_events.each do |event|
      collection.push(
                      nct_id: nct_id,
                      event: event['UnpostedEventType'],
                      event_date_description: event['UnpostedEventDate'],
                      event_date: event['UnpostedEventDate'].try(:to_date)
                    )
    end
    collection
  end

  def provided_documents_data
    large_document_module = key_check(document_section['LargeDocumentModule'])
    large_doc_list = key_check(large_document_module['LargeDocList'])
    large_docs = large_doc_list['LargeDoc'] || []
    collection = []
    return nil if large_docs.empty?

    large_docs.each do |doc|
      collection.push(
                      nct_id: nct_id,
                      document_type: doc['LargeDocLabel'],
                      has_protocol: get_boolean(doc['LargeDocHasProtocol']),
                      has_icf: get_boolean(doc['LargeDocHasICF']),
                      has_sap: get_boolean(doc['LargeDocHasSAP']),
                      document_date: doc['LargeDocDate'].try(:to_date),
                      url: doc['LargeDocFilename']
                      )
                    
    end
    collection
  end
 
  def reported_events_data
    adverse_events_module = key_check(results_section['AdverseEventsModule'])
    event_group_list = key_check(adverse_events_module['EventGroupList'])
    event_groups = event_group_list['EventGroup'] || []
    events = events_data('Serious') + events_data('Other')
    return nil if events.empty?

    {
      result_groups: StudyJsonRecord.result_groups(event_groups, 'Event', 'Reported Event', nct_id),
      events: events 
    }
  end

  def events_data(event_type='Serious')
    adverse_events_module = key_check(results_section['AdverseEventsModule'])
    event_list = key_check(adverse_events_module["#{event_type}EventList"])
    events = event_list["#{event_type}Event"] || []
    collection = []

    events.each do |event|
      event_stat_list = key_check(event["#{event_type}EventStatsList"])
      event_stats = event_stat_list["#{event_type}EventStats"] || []
      event_stats.each do |event_stat|
        collection.push(
                        nct_id: nct_id,
                        result_group_id: nil,
                        ctgov_group_code: event_stat["#{event_type}EventStatsGroupId"],
                        time_frame: adverse_events_module['EventsTimeFrame'],
                        event_type: event_type.downcase,
                        default_vocab: event["#{event_type}EventSourceVocabulary"],
                        default_assessment: event["#{event_type}EventAssessmentType"],
                        subjects_affected: event_stat["#{event_type}EventStatsNumAffected"],
                        subjects_at_risk: event_stat["#{event_type}EventStatsNumAtRisk"],
                        description: adverse_events_module['EventsDescription'],
                        event_count: event_stat["#{event_type}EventStatsNumEvents"],
                        organ_system: event["#{event_type}EventOrganSystem"],
                        adverse_event_term: event["#{event_type}EventTerm"],
                        frequency_threshold: adverse_events_module['EventsFrequencyThreshold'],
                        vocab: nil,
                        assessment: event["#{event_type}EventAssessmentType"]
        )
      end
    end
    collection
  end

  def responsible_party_data
    # https://clinicaltrials.gov/api/query/full_studies?expr=NCT04053270&fmt=json
    # https://clinicaltrials.gov/api/query/full_studies?expr=NCT04076787&fmt=json
    sponsor_collaborators_module = key_check(protocol_section['SponsorCollaboratorsModule'])
    responsible_party = key_check(sponsor_collaborators_module['ResponsibleParty'])
    return nil if responsible_party.empty?

    {
      nct_id: nct_id,
      responsible_party_type: responsible_party['ResponsiblePartyType'],
      name: responsible_party['ResponsiblePartyInvestigatorFullName'],
      title: responsible_party['ResponsiblePartyInvestigatorTitle'],
      organization: responsible_party['ResponsiblePartyOldOrganization'],
      affiliation: responsible_party['ResponsiblePartyInvestigatorAffiliation']
    }
  end

  def result_agreement_data
    more_info_module = key_check(results_section['MoreInfoModule'])
    certain_agreement = key_check(more_info_module['CertainAgreement'])
    return nil if certain_agreement.empty?

    {
      nct_id: nct_id,
      pi_employee: certain_agreement['AgreementPISponsorEmployee'],
      restrictive_agreement: certain_agreement['AgreementOtherDetails'],
      restriction_type: certain_agreement['AgreementRestrictionType'],
      other_details: certain_agreement['AgreementOtherDetails']
    }
  end

  def result_contact_data
    more_info_module = key_check(results_section['MoreInfoModule'])
    point_of_contact = key_check(more_info_module['PointOfContact'])
    return nil if point_of_contact.empty?

    ext = point_of_contact['PointOfContactPhoneExt']
    phone = point_of_contact['PointOfContactPhone']

    {
      nct_id: nct_id,
      organization: point_of_contact['PointOfContactOrganization'], 
      name: point_of_contact['PointOfContactTitle'], 
      phone: ext ? (phone + " ext #{ext}") : phone, 
      email: point_of_contact['PointOfContactEMail']
    }
  end

  def study_references_data
    reference_module = key_check(protocol_section['ReferencesModule'])
    reference_list = key_check(reference_module['ReferenceList'])
    references = reference_list['Reference'] || []
    collection = []
    return nil if references.empty?

    references.each do |reference|
      collection.push(
                      nct_id: nct_id,
                      pmid: reference['ReferencePMID'],
                      reference_type: reference['ReferenceType'],
                      # results_reference - old data format
                      citation: reference['ReferenceCitation']

                      )
    end
    collection
  end

  def sponsors_data
    sponsor_collaborators_module = key_check(protocol_section['SponsorCollaboratorsModule'])
    lead_sponsor = key_check(sponsor_collaborators_module['LeadSponsor'])
    collaborator_list = key_check(sponsor_collaborators_module['CollaboratorList'])
    collaborators = collaborator_list['Collaborator'] || []
    collection = []
    lead_info = sponsor_info(lead_sponsor, 'LeadSponsor')
    return nil if lead_info.nil? && collaborators.empty?

    collection.push(lead_info) unless lead_info.nil?

    collaborators.each do |collaborator|
      info = sponsor_info(collaborator, 'Collaborator')
      collection.push(info) unless info.nil?
    end

    collection
  end

  def sponsor_info(sponsor_hash, sponsor_type='LeadSponsor')
    type_of_sponsor = sponsor_type =~ /Lead/i ? 'lead' : 'collaborator'
    return nil if sponsor_hash.empty?

    {
      nct_id: nct_id,
      agency_class: sponsor_hash["#{sponsor_type}Class"],
      lead_or_collaborator: type_of_sponsor,
      name: sponsor_hash["#{sponsor_type}Name"]
    }
  end

  def self.new_check
    nct = %w[
      NCT04050527
      NCT00530010
      NCT04144088
      NCT04053270
      NCT03897712
      NCT03845673
      NCT04245423
      NCT03519243
      NCT03034044
      NCT03496987
      NCT04204200
      NCT04182217
      NCT04167644
      NCT04214080
      NCT02982187
      NCT04027218
      NCT03811093
      NCT04109703
      NCT03763058
      NCT00489281
      NCT04076787
      NCT00725621
      NCT02222493
      NCT04014062
    ]
    
    
    # StudyJsonRecord.where(nct_id: nct).each{ |i| puts i.study_data }
    StudyJsonRecord.all.order(:id).each{ |i| puts i.study_data }
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
      keywords: keywords_data,
      links: links_data,
      milestones: milestones_data,
      outcomes: outcomes_data,
      overall_officials: overall_officials_data,
      design_outcomes: design_outcomes_data,
      pending_results: pending_results_data,
      provided_documents: provided_documents_data,
      reported_events: reported_events_data,
      responsible_party: responsible_party_data,
      result_agreement: result_agreement_data,
      result_contact: result_contact_data,
      study_references: study_references_data,
      sponsors: sponsors_data
    }
  end

  def build_study
    data = data_collection
    StudyJsonRecord.set_table_schema('ctgov_beta')

    Study.find_or_create_by(nct_id: nct_id).update(data[:study]) if data[:study]
    
    # saving design_groups, and associated objects
    save_interventions(data[:interventions])
    save_design_groups(data[:design_groups])

    DetailedDescription.find_or_create_by(nct_id: nct_id).update(data[:detailed_description]) if data[:detailed_description]
    BriefSummary.find_or_create_by(nct_id: nct_id).update(data[:brief_summary]) if data[:brief_summary]
    Design.find_or_create_by(nct_id: nct_id).update(data[:design]) if data[:design]
    Eligibility.find_or_create_by(nct_id: nct_id).update(data[:eligibility]) if data[:eligibility]
    ParticipantFlow.find_or_create_by(nct_id: nct_id).update(data[:participant_flow]) if data[:participant_flow]
    
    # saving baseline_measurements and associated objects
    baseline_info = data[:baseline_measurements]
    ResultGroup.create(baseline_info[:result_groups]) if baseline_info
    save_with_result_group(baseline_info[:baseline_counts], 'BaselineCount') if baseline_info
    save_with_result_group(baseline_info[:measurements], 'BaselineMeasurement') if baseline_info
    
    BrowseCondition.create(data[:browse_conditions]) if data[:browse_conditions]
    BrowseIntervention.create(data[:browse_interventions]) if data[:browse_interventions]
    CentralContact.create(data[:central_contacts_list]) if data[:central_contacts_list]
    Condition.create(data[:conditions]) if data[:conditions]
    Country.create(data[:countries]) if data[:countries]
    Document.create(data[:documents]) if data[:documents]

    # saving facilities and related objects
    save_facilities(data[:facilities])

    IdInformation.create(data[:id_information]) if data[:id_information]
    IpdInformationType.create(data[:ipd_information_type]) if data[:ipd_information_type]
    Keyword.create(data[:keywords]) if data[:keywords]
    Link.create(data[:links]) if data[:links]

    # saving milestones and associated objects
    milestone_info = data[:milestones] || {}
    ResultGroup.create(milestone_info[:result_groups]) if milestone_info[:result_groups]
    save_with_result_group(milestone_info[:milestones], 'Milestone') if milestone_info[:milestones]

    # saving outcomes and associated objects
    outcomes_info = data[:outcomes] || {}
    ResultGroup.create(outcomes_info[:result_groups]) if outcomes_info[:result_groups]
    save_outcomes(outcomes_info[:outcome_measures]) if outcomes_info[:outcome_measures]

    OverallOfficial.create(data[:overall_officials]) if data[:overall_officials]
    DesignOutcome.create(data[:design_outcomes]) if data[:design_outcomes]
    PendingResult.create(data[:pending_results]) if data[:pending_results]
    

    puts StudyJsonRecord.object_counts
    
    puts "~~~~~~~~~~~~~~"
    puts 'here we create/update studies and all associated models'
    # StudyJsonRecord.set_table_schema('ctgov')
  end

  def self.object_counts
    {
      study: Study.count,
      intervention: Intervention.count,
      intervention_other_name: InterventionOtherName.count,
      design_group: DesignGroup.count,
      design_group_intervention: DesignGroupIntervention.count,
      detailed_description: DetailedDescription.count,
      brief_summary: BriefSummary.count,
      design: Design.count,
      eligibility: Eligibility.count,
      participant_flow: ParticipantFlow.count,
      result_groups: ResultGroup.count,
      baseline_count: BaselineCount.count,
      baseline_measurement: BaselineMeasurement.count,
      browse_condition: BrowseCondition.count,
      browse_intervention: BrowseIntervention.count,
      central_contact: CentralContact.count,
      condition: Condition.count,
      country: Country.count,
      document: Document.count,
      facility: Facility.count,
      facility_contact: FacilityContact.count,
      facility_investigator: FacilityInvestigator.count,
      id_information: IdInformation.count,
      ipd_information_type: IpdInformationType.count,
      keyword: Keyword.count,
      link: Link.count,
      milestone: Milestone.count,
      outcome: Outcome.count,
      outcome_count: OutcomeCount.count,
      outcome_measurement: OutcomeMeasurement.count,
      outcome_analysis: OutcomeAnalysis.count,
      outcome_analysis_group: OutcomeAnalysisGroup.count,
      overall_official: OverallOfficial.count,
      design_outcome: DesignOutcome.count,
      pending_result: PendingResult.count,
    }
  end

  def self.set_table_schema(schema = 'ctgov')
    return unless schema == 'ctgov' || schema == 'ctgov_beta'   
    
    table_names = Util::DbManager.new.loadable_tables
    table_names.each do |name|
      model_name = name.singularize.camelize.safe_constantize
      model_name.table_name = schema + ".#{name}" if model_name
      puts model_name.table_name if model_name
    end
  end

  def save_interventions(interventions)
    return unless interventions

    interventions.each do |intervention_info|
      info = intervention_info[:intervention]
      intervention = Intervention.find_or_create_by(nct_id: nct_id, name: info[:name])
      intervention.update(info)
      intervention_other_names = intervention_info[:intervention_other_names]
      next unless intervention_other_names

      intervention_other_names.each do |name|
        name[:intervention_id] = intervention.id
        InterventionOtherName.find_or_create_by(name)
      end
    end
  end

  def save_design_groups(design_groups)
    return unless design_groups

    design_groups.each do |group|
      design_info = group[:design_group]
      design_group = DesignGroup.find_by(nct_id: nct_id, title: design_info[:title])
      design_group ||= DesignGroup.create(nct_id: nct_id, title: design_info[:title])
      design_group.update(design_info)

      interventions = group[:design_group_interventions]
      next unless interventions

      interventions.each do |intervention_info|
        intervention = Intervention.find_by(
                                            nct_id: nct_id,
                                            name: intervention_info[:name],
                                            intervention_type: intervention_info[:type]
                                            )
        next unless intervention

        DesignGroupIntervention.find_or_create_by(
                                                  nct_id: nct_id,
                                                  design_group_id: design_group.id,
                                                  intervention_id: intervention.id
                                                  )
      end
    end
  end

  def save_baseline_counts(counts)
    return unless counts

    counts.each do |count|
      result_group = ResultGroup.find_by(nct_id: nct_id, ctgov_group_code: count[:ctgov_group_code])
      next unless result_group

      count[:result_group_id] = result_group.id
      BaselineCount.find_or_create_by(count)
    end
  end

  def save_with_result_group(group, model_name='BaselineMeasurement')
    return unless group

    group.each do |item|
      result_group = ResultGroup.find_by(nct_id: nct_id, ctgov_group_code: item[:ctgov_group_code])
      next unless result_group

      item[:result_group_id] = result_group.id
      model_name.safe_constantize.find_or_create_by(item)
    end
  end

  def save_facilities(facilities)
    return unless facilities

    facilities.each do |facility_info|
      facility = Facility.create(facility_info[:facility]) if facility_info[:facility]
      next unless facility

      facility_info[:facility_contacts].each{|h| h[:facility_id] = facility.id}
      facility_info[:facility_investigators].each{|h| h[:facility_id] = facility.id}
      FacilityContact.create(facility_info[:facility_contacts]) if facility_info[:facility_contacts]
      FacilityInvestigator.create(facility_info[:facility_investigators]) if facility_info[:facility_investigators]
    end
  end

  def save_outcomes(outcome_measures)
    return unless outcome_measures

    outcome_measures.each do |outcome_measure|
      outcome = Outcome.create(outcome_measure[:outcome_measure]) if outcome_measure[:outcome_measure]
      next unless outcome

      outcome_counts = StudyJsonRecord.set_key_value(outcome_measure[:outcome_counts], :outcome_id, outcome.id)
      outcome_measurements = StudyJsonRecord.set_key_value(outcome_measure[:outcome_measurements], :outcome_id, outcome.id)
      outcome_analyses = outcome_measure[:outcome_analyses]
      analyses = StudyJsonRecord.set_key_value(outcome_analyses[:outcome_analysis], :outcome_id, outcome.id) if outcome_analyses
      
      save_with_result_group(outcome_counts, 'OutcomeCount') if outcome_counts
      save_with_result_group(outcome_measurements, 'OutcomeMeasurement') if outcome_measurements
      save_with_result_group(analyses, 'OutcomeAnalysis') if analyses
      save_outcome_analyses(outcome_analyses[:outcome_analysis_group_ids]) if outcome_analyses
    end
  end

  def save_outcome_analyses(outcome_analysis_groups)
    return unless outcome_analysis_groups

    outcome_analysis_groups.each do |group|
      analysis = OutcomeAnalysis.find_by(nct_id: nct_id, ctgov_group_code: outcome_analysis[:ctgov_group_code])
      result_group = ResultGroup.find_by(nct_id: nct_id, ctgov_group_code: outcome_analysis[:ctgov_group_code])
      next unless result_group && analysis

      StudyJsonRecord.set_key_value(group, :outcome_analysis_id, analysis.id)
      save_with_result_group(group, 'OutcomeAnalysisGroup')
    end
  end

  def self.set_key_value(hash_array, key, value)
    return unless hash_array
    
    hash_array.map{ |h| h[key] = value }
    hash_array
  end
end
