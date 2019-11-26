class StudyJsonRecord < ActiveRecord::Base
  def collect_attributes
    deep_info = content['Study']['ProtocolSection']['StatusModule']
    {
      :start_month_year              => deep_info['StartDateStruct']['StartDate'],
      :verification_month_year       => deep_info['StatusVerifiedDate'],
      :completion_month_year         => deep_info['CompletionDateStruct']['CompletionDate'],
      :primary_completion_month_year => deep_info['PrimaryCompletionDateStruct']['PrimaryCompletionDate'],

      :start_date                    => convert_date(deep_info['StartDateStruct']['StartDate']),
      :verification_date             => convert_date(deep_info['StatusVerifiedDate']),
      :completion_date               => convert_date(deep_info['CompletionDateStruct']['CompletionDate']),
      :primary_completion_date       => convert_date(deep_info['PrimaryCompletionDateStruct']['PrimaryCompletionDate']),

      :study_first_submitted_qc_date        => get(deep_info['StudyFirstSubmitQCDate']).try(:to_date),
      :study_first_posted_date              => get(deep_info['StudyFirstPostDateStruct']['StudyFirstPostDate']).try(:to_date),
      :results_first_submitted_qc_date      => get('results_first_submitted_qc').try(:to_date),
      :results_first_posted_date            => get('results_first_posted').try(:to_date),
      :disposition_first_submitted_qc_date  => get('disposition_first_submitted_qc').try(:to_date),
      :disposition_first_posted_date        => get('disposition_first_posted').try(:to_date),
      :last_update_submitted_qc_date        => get(deep_info['LastUpdateSubmitDate']).try(:to_date),
      :last_update_posted_date              => get(deep_info['LastUpdatePostDateStruct']['LastUpdatePostDate']).try(:to_date),

      # the previous have been replaced with:
      :study_first_submitted_date       => get_date(get('study_first_submitted')),
      :results_first_submitted_date     => get_date(get('results_first_submitted')),
      :disposition_first_submitted_date => get_date(get('disposition_first_submitted')),
      :last_update_submitted_date       => get_date(get('last_update_submitted')),

      :nlm_download_date_description  => xml.xpath('//download_date').text,
      :acronym                        => get('acronym'),
      :baseline_population            => xml.xpath('//baseline/population').try(:text),
      :number_of_arms                 => get('number_of_arms'),
      :number_of_groups               => get('number_of_groups'),
      :source                         => get('source'),
      :brief_title                    => get('brief_title') ,
      :official_title                 => get('official_title'),
      :overall_status                 => get('overall_status'),
      :last_known_status              => get('last_known_status'),
      :phase                          => get('phase'),
      :target_duration                => get('target_duration'),
      :enrollment                     => get('enrollment'),
      :biospec_description            => get_text('biospec_descr'),

      :start_date_type                     => get_type('start_date'),
      :primary_completion_date_type        => get_type('primary_completion_date'),
      :completion_date_type                => get_type('completion_date'),
      :study_first_posted_date_type        => get_type('study_first_posted'),
      :results_first_posted_date_type      => get_type('results_first_posted'),
      :disposition_first_posted_date_type  => get_type('disposition_first_posted'),
      :last_update_posted_date_type        => get_type('last_update_posted'),
      :enrollment_type                     => get_type('enrollment'),

      :study_type                        => get('study_type'),
      :biospec_retention                 => get('biospec_retention'),
      :limitations_and_caveats           => xml.xpath('//limitations_and_caveats').text,
      :is_fda_regulated_drug             => get_boolean('//is_fda_regulated_drug'),
      :is_fda_regulated_device           => get_boolean('//is_fda_regulated_device'),
      :is_unapproved_device              => get_boolean('//is_unapproved_device'),
      :is_ppsd                           => get_boolean('//is_ppsd'),
      :is_us_export                      => get_boolean('//is_us_export'),
      :ipd_time_frame                    => get('patient_data/ipd_time_frame'),
      :ipd_access_criteria               => get('patient_data/ipd_access_criteria'),
      :ipd_url                           => get('patient_data/ipd_url'),
      :plan_to_share_ipd                 => get('patient_data/sharing_ipd'),
      :plan_to_share_ipd_description     => get('patient_data/ipd_description'),
      :has_expanded_access               => get_boolean('//has_expanded_access'),
      :expanded_access_type_individual   => get_boolean('//expanded_access_info/expanded_access_type_individual'),
      :expanded_access_type_intermediate => get_boolean('//expanded_access_info/expanded_access_type_intermediate'),
      :expanded_access_type_treatment    => get_boolean('//expanded_access_info/expanded_access_type_treatment'),
      :has_dmc                           => get_boolean('//has_dmc'),
      :why_stopped                       => get('why_stopped')
    }
  end

  def true_attrib
    body = content['Study']['ProtocolSection']
    status = body['StatusModule']
    ident = body['IdentificationModule']
    { 
      nct_id: nct_id,
      nlm_download_date_description: nil,
      study_first_submitted_date: status['StudyFirstSubmitDate'],
      results_first_submitted_date: nil,
      disposition_first_submitted_date: nil,
      last_update_submitted_date: status['LastUpdateSubmitDate'],
      study_first_submitted_qc_date: status['StudyFirstSubmitQCDate'],
      study_first_posted_date: status['StudyFirstPostDateStruct']['StudyFirstPostDate'],
      study_first_posted_date_type: status['StudyFirstPostDateStruct']['StudyFirstPostDateType'],
      results_first_submitted_qc_date: nil,
      results_first_posted_date: nil,
      results_first_posted_date_type: nil,
      disposition_first_submitted_qc_date: nil,
      disposition_first_posted_date: nil,
      disposition_first_posted_date_type: nil,
      last_update_submitted_qc_date: nil,
      last_update_posted_date: study['LastUpdatePostDateStruct']['LastUpdatePostDate'],
      last_update_posted_date_type: study['LastUpdatePostDateStruct']['LastUpdatePostDateType'],
      start_month_year: nil,
      start_date_type: status['StartDateStruct']['StartDateType'],
      start_date: status['StartDateStruct']['StartDate'],
      verification_month_year: status['StatusVerifiedDate'],
      verification_date: status['StatusVerifiedDate'],
      completion_month_year: nil,
      completion_date_type: status['CompletionDateStruct']['CompletionDateType'],
      completion_date: status['CompletionDateStruct']['CompletionDate'],
      primary_completion_month_year: nil,
      primary_completion_date_type: nilstatus['PrimaryCompletionDateStruct']['PrimaryCompletionDateType'],
      primary_completion_date: status['PrimaryCompletionDateStruct']['PrimaryCompletionDate'],
      target_duration: nil,
      study_type: body['DesignModule']['StudyType'],
      acronym: ident['Acronym'],
      baseline_population: nil,
      brief_title: ident['BriefTitle'],
      official_title: ident['OfficialTitle'],
      overall_status: status['OverallStatus'],
      last_known_status: nil,
      phase: body['DesignModule']['PhaseList']['Phase'],
      enrollment: body['EnrollmentInfo']['EnrollmentCount'],
      enrollment_type: body['EnrollmentInfo']['EnrollmentType'],
      source: nil,
      limitations_and_caveats: nil,
      number_of_arms: nil,
      number_of_groups: nil,
      why_stopped: nil,
      has_expanded_access: nil,
      expanded_access_type_individual: nil,
      expanded_access_type_intermediate: nil,
      expanded_access_type_treatment: nil,
      has_dmc: body['OversightModule']['OversightHasDMC'],
      is_fda_regulated_drug: body['OversightModule']['IsFDARegulatedDrug'],
      is_fda_regulated_device: body['OversightModule']['IsFDARegulatedDevice'],
      is_unapproved_device: nil,
      is_ppsd: nil,
      is_us_export: nil,
      biospec_retention: nil,
      biospec_description: nil,
      ipd_time_frame: nil,
      ipd_access_criteria: nil,
      ipd_url: nil,
      plan_to_share_ipd: nil,
      plan_to_share_ipd_description: nil,
      created_at: nil,
      updated_at: nil 
    }
  end

  def convert_date(date)
    return nil if date.nil?
    return date.to_date.end_of_month if date.is_missing_the_day?
    return data.to_date
  end
end
