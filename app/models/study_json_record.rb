require 'open-uri'
class StudyJsonRecord < ActiveRecord::Base
  def self.save_all_studies
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
    
    for x in 416..limit
      puts "batch #{x}"
      fetch_studies(min, max)
      min += 100
      max += 100
      puts "Current Study Record Count #{StudyJsonRecord.count}"
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
    if record.save
      puts study_data['Study']['ProtocolSection']['IdentificationModule']['NCTId']
    else
      puts "failed to save #{nct_id}"
    end
  end

  def self.json_data(url='https://clinicaltrials.gov/api/query/full_studies?expr=&min_rnk=1&max_rnk=100&fmt=json')
    page = open(url)
    JSON.parse(page.read)
  end

  def key_check(key)
    return key if key
      
    {}
  end

  def self.check
    all.each{|sjr| sjr.attrib_hash}
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
  
  def attrib_hash
    puts "Study Record #{id}"
    protocol = content['Study']['ProtocolSection']
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
end
