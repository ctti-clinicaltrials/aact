
class StudyRelationship < ActiveRecord::Base

  def xml_study_data
    { 
      nct_id: nct_id,
      nlm_download_date_description: xml.xpath('//download_date').text,
      study_first_submitted_date: get_date(get('study_first_submitted')),
      results_first_submitted_date: get_date(get('results_first_submitted')),
      disposition_first_submitted_date: get_date(get('disposition_first_submitted')),
      last_update_submitted_date: get_date(get('last_update_submitted')),
      
      study_first_submitted_qc_date: get('study_first_submitted_qc').try(:to_date),
      study_first_posted_date: get('study_first_posted').try(:to_date),
      study_first_posted_date_type: get_type('study_first_posted'),
      
      results_first_submitted_qc_date: get('results_first_submitted_qc').try(:to_date),
      results_first_posted_date: get('results_first_posted').try(:to_date),
      results_first_posted_date_type: get_type('results_first_posted'),
      
      disposition_first_submitted_qc_date: get('disposition_first_submitted_qc').try(:to_date),
      disposition_first_posted_date: get('disposition_first_posted').try(:to_date),
      disposition_first_posted_date_type: get_type('disposition_first_posted'),
      
      last_update_submitted_qc_date: get('last_update_submitted_qc').try(:to_date),
      last_update_posted_date: get('last_update_posted').try(:to_date)
      last_update_posted_date_type: get_type('last_update_posted'),
      
      start_month_year: => get('start_date'),
      start_date_type: get_type('start_date'),
      start_date: convert_date('start_date'),

      verification_month_year: get('verification_date'),
      verification_date: convert_date('verification_date'),
      
      completion_month_year: get('completion_date'),
      completion_date_type: get_type('completion_date'),
      completion_date: convert_date('completion_date'),
      
      primary_completion_month_year: get('primary_completion_date'),
      primary_completion_date_type:  get_type('primary_completion_date'),
      primary_completion_date: convert_date('primary_completion_date'),
      
      target_duration: get('target_duration'),
      study_type: get('study_type'),
      acronym: get('acronym'),
      baseline_population: xml.xpath('//baseline/population').try(:text),
      brief_title:  get('brief_title'),
      official_title: get('official_title'),
      overall_status: get('overall_status'),
      last_known_status: get('last_known_status'),
      phase: get('phase'),

      enrollment: get('enrollment'),
      enrollment_type: get_type('enrollment'),

      source:  get('source'),
      limitations_and_caveats: xml.xpath('//limitations_and_caveats').text,
      number_of_arms: get('number_of_arms'),
      number_of_groups: get('number_of_groups'),
      why_stopped: get('why_stopped'),

      has_expanded_access: get_boolean('//has_expanded_access'),
      expanded_access_type_individual: get_boolean('//expanded_access_info/expanded_access_type_individual'),
      expanded_access_type_intermediate: get_boolean('//expanded_access_info/expanded_access_type_intermediate'),
      expanded_access_type_treatment: get_boolean('//expanded_access_info/expanded_access_type_treatment'),
      
      has_dmc: get_boolean('//has_dmc'),
      
      is_fda_regulated_drug: get_boolean('//is_fda_regulated_drug'),
      is_fda_regulated_device: get_boolean('//is_fda_regulated_device'),
      is_unapproved_device:  get_boolean('//is_unapproved_device'),
      is_ppsd: get_boolean('//is_ppsd'),
      is_us_export: get_boolean('//is_us_export'),
      
      biospec_retention: get('biospec_retention'),
      biospec_description: get_text('biospec_descr'),
      
      ipd_time_frame: get('patient_data/ipd_time_frame'),
      ipd_access_criteria: get('patient_data/ipd_access_criteria'),
      ipd_url: get('patient_data/ipd_url',
      plan_to_share_ipd: get('patient_data/sharing_ipd'),
      plan_to_share_ipd_description: get('patient_data/ipd_description')
    }
  end

  def get(label)
    value=(xml.xpath('//clinical_study').xpath("#{label}").text).strip
    value2=(xml.xpath('//clinical_study').xpath("#{label}"))
    value=='' ? nil : value
  end

  def get_text(label)
    str=''
    nodes=xml.xpath("//#{label}")
    nodes.each {|node| str << node.xpath("textblock").text}
    str
  end

  def get_type(label)
    node=xml.xpath("//#{label}")
    node.attribute('type').try(:value) if !node.blank?
  end

  def get_boolean(label)
    val=xml.xpath("#{label}").try(:text)
    return nil if val.blank?
    return true if val.downcase=='yes'||val.downcase=='y'||val.downcase=='true'
    return false if val.downcase=='no'||val.downcase=='n'||val.downcase=='false'
  end

  def get_date(str)
    Date.parse(str) if !str.blank?
  end

  def convert_date(label)
    dt=get(label)
    return nil if dt.nil?
    return dt.to_date.end_of_month if dt.is_missing_the_day?
    return dt.to_date
  end
end