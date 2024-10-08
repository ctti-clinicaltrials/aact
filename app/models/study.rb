class String
  def is_missing_the_day?
    # use this method on string representations of dates.  If only one space in the string, then the day is not provided.
    (count ' ') == 1
  end
end

class Study < ApplicationRecord

  attr_accessor :xml, :with_related_records, :with_related_organizations

  

  def as_indexed_json(options = {})
    self.as_json({
      only: [:nct_id, :acronym, :brief_title, :overall_status, :phase, :start_date, :primary_completion_date],
      include: {
        browse_conditions: { only: :mesh_term },
        browse_interventions: { only: :mesh_term },
        keywords: { only: :name },
        sponsors: { only: :name },
      }
    })
  end

  def self.current_interventional
    self.interventional and self.current
  end

  scope :started_between, lambda {|sdate, edate| where("start_date >= ? AND created_at <= ?", sdate, edate )}
  scope :changed_since,   lambda {|cdate| where("last_changed_date >= ?", cdate )}
  scope :completed_since, lambda {|cdate| where("completion_date >= ?", cdate )}
  scope :sponsored_by,    lambda {|agency| joins(:sponsors).where("sponsors.agency LIKE ?", "#{agency}%")}
  scope :with_one_to_ones,   -> { joins(:eligibility, :brief_summary, :design, :detailed_description) }
  scope :with_organizations, -> { joins(:sponsors, :facilities, :central_contacts, :responsible_parties) }

  scope :study_dates_for_calculations, -> (nct_ids) {
    where(nct_id: nct_ids)
    .select(:nct_id, :start_date, :start_date_type, :primary_completion_date, :primary_completion_date_type, :results_first_submitted_date, :study_first_submitted_date)
  }

  self.primary_key = 'nct_id'

  has_one  :brief_summary,         :foreign_key => 'nct_id', :dependent => :delete
  has_one  :design,                :foreign_key => 'nct_id', :dependent => :delete
  has_one  :detailed_description,  :foreign_key => 'nct_id', :dependent => :delete
  has_one  :eligibility,           :foreign_key => 'nct_id', :dependent => :delete
  has_one  :participant_flow,      :foreign_key => 'nct_id', :dependent => :delete
  has_one  :calculated_value,      :foreign_key => 'nct_id', :dependent => :delete

  has_many :search_results,            :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :baseline_measurements, :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :baseline_counts,       :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :browse_conditions,     :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :browse_interventions,  :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :central_contacts,      :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :conditions,            :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :countries,             :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :design_outcomes,       :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :design_groups,         :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :design_group_interventions, :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :documents,             :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :drop_withdrawals,      :foreign_key => 'nct_id', :dependent => :delete_all

  has_many :facilities,            :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :facility_contacts,     :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :facility_investigators,:foreign_key => 'nct_id', :dependent => :delete_all
  has_many :id_information,        :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :interventions,         :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :intervention_other_names, :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :ipd_information_types, :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :keywords,              :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :links,                 :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :milestones,            :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :outcomes,              :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :outcome_analysis_groups, :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :outcome_analyses,      :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :outcome_measurements,  :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :overall_officials,     :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :pending_results,       :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :provided_documents,    :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :references,            :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :reported_events,       :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :reported_event_totals, :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :responsible_parties,   :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :result_agreements,     :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :result_contacts,       :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :result_groups,         :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :sponsors,              :foreign_key => 'nct_id', :dependent => :delete_all
  accepts_nested_attributes_for :outcomes

  def remove_study_data
    s = Time.now
    StudyRelationship.study_models.each do |model|
      model.where(nct_id: nct_id).delete_all
    end
    time = Time.now - s
    puts "  remove-study #{time}"
  end

  def self.remove_studies_data(nct_ids)
    ids = nct_ids.map { |i| "'#{i}'" }.join(",")
    StudyRelationship.study_models.each do |table|
      connection.execute("DELETE FROM #{table} WHERE nct_id IN (#{ids})")
    end
  end

  def self.study_difference
    ClinicalTrialsApi.number_of_studies - Study.count
  end

  def opts
    {
      :xml=>xml,
      :nct_id=>nct_id
    }
  end

  def self.all_nctids
    all.collect{|s|s.nct_id}
  end

  def set_downcase
    con=ActiveRecord::Base.connection
    con.execute("UPDATE browse_conditions SET downcase_mesh_term=lower(mesh_term) where nct_id = '#{nct_id}';")
    con.execute("UPDATE browse_interventions SET downcase_mesh_term=lower(mesh_term) where nct_id = '#{nct_id}';")
    con.execute("UPDATE keywords SET downcase_name=lower(name) where nct_id = '#{nct_id}';")
    con.execute("UPDATE conditions SET downcase_name=lower(name) where nct_id = '#{nct_id}';")
  end

  def summary
    brief_summary.description
  end

  def sampling_method
    eligibility.sampling_method
  end

  def study_population
    eligibility.study_population
  end

  def study_references
    references.select{|r|r.type!='results_reference'}
  end

  def result_references
    references.select{|r|r.type=='results_reference'}
  end

  def healthy_volunteers?
    eligibility.healthy_volunteers
  end

  def minimum_age
    eligibility.minimum_age
  end

  def maximum_age
    eligibility.maximum_age
  end

  def age_range
    "#{minimum_age} - #{maximum_age}"
  end

  def lead_sponsors
    sponsors.where(lead_or_collaborator: 'lead')
  end

  def collaborators
    sponsors.where(lead_or_collaborator: 'collaborator')
  end

  def lead_sponsor_names
    lead_sponsors.select{|s|s.name}
  end

  def number_of_sites
    facilities.size
  end

  def pi
    val=''
    responsible_parties.each{|r|val=r.investigator_full_name if r.responsible_party_type=='Principal Investigator'}
    val
  end

  def status
    overall_status
  end

  def name
    brief_title
  end

  def get_groups(opts)
    self.groups=ResultGroup.create_all_from(opts)
  end

  def convert_date(label)
    dt=get(label)
    return nil if dt.nil?
    return dt.to_date.end_of_month if dt.is_missing_the_day?
    return dt.to_date
  end

  def outcome_analyses
    OutcomeAnalysis.where('nct_id=?',nct_id)
  end

  def outcome_measurements
    OutcomeMeasurement.where('nct_id=?',nct_id)
  end

  def outcome_counts
    OutcomeCount.where('nct_id=?',nct_id)
  end

  def intervention_names
    interventions.collect{|x|x.name}.join(', ')
  end

  def condition_names
    conditions.collect{|x|x.name}.join(', ')
  end

  def prime_address
    #  This isn't real.  Just proof of concept.
    return facilities.first.address if facilities.size > 0
    return lead_sponsor.agency
  end

  def completed_since(aDate)
  end

  def has(attrib,label)
		!pick(attrib,label).nil?
	end

  def pick(attrib,label)
    # generic way to find element in one-to-many attrib with the 'label'
    if send(attrib).respond_to? :proxy_association
      col=send(attrib.to_sym)
      val=col.select{|x|x.title==label if x.respond_to? :title}.first
      return val if val
      val=col.select{|x|x.label==label if x.respond_to? :label}.first
      return val if val
      val=col.select{|x|x.name==label if x.respond_to? :name}.first
      return val if val
      val=col.select{|x|x.id_type==label if x.respond_to? :id_type}.first
      return val if val
    else
      col.send(attrib).send(label)
    end
  end

  def self.with_organization(user_provided_org)
    org=make_queriable(user_provided_org)
    ids=(ResponsibleParty.where('organization like ?',"%#{org}%").pluck(:nct_id) \
      + OverallOfficial.where('affiliation like ?',"%#{org}%").pluck(:nct_id) \
      + Facility.where('name like ?',"%#{org}%").pluck(:nct_id) \
      + where('source like ?',"%#{org}%").pluck(:nct_id)).flatten.uniq
    where(nct_id: ids).includes(:sponsors).includes(:facilities).includes(:brief_summary).includes(:detailed_description).includes(:design).includes(:eligibility).includes(:overall_officials).includes(:responsible_parties)
  end

  StudyRelationship.add_mapping do
    {
      table: :studies,
      root: nil,
      columns: [
        { name: :study_first_submitted_date, value: [:protocolSection, :statusModule, :studyFirstSubmitDate], convert_to: :date },
        { name: :study_first_submitted_qc_date, value: [:protocolSection, :statusModule, :studyFirstSubmitQcDate], convert_to: :date },
        { name: :study_first_posted_date, value: [:protocolSection, :statusModule, :studyFirstPostDateStruct, :date], convert_to: :date },
        { name: :study_first_posted_date_type, value: [:protocolSection, :statusModule, :studyFirstPostDateStruct, :type] },
        { name: :results_first_submitted_date, value: [:protocolSection, :statusModule, :resultsFirstSubmitDate], convert_to: :date },
        { name: :results_first_submitted_qc_date, value: [:protocolSection, :statusModule, :resultsFirstSubmitQcDate], convert_to: :date },
        { name: :results_first_posted_date, value: [:protocolSection, :statusModule, :resultsFirstPostDateStruct, :date], convert_to: :date },
        { name: :results_first_posted_date_type, value: [:protocolSection, :statusModule, :resultsFirstPostDateStruct, :type] },
        { name: :disposition_first_submitted_date, value: [:protocolSection, :statusModule, :dispFirstSubmitDate], convert_to: :date },
        { name: :disposition_first_submitted_qc_date, value: [:protocolSection, :statusModule, :dispFirstSubmitQcDate], convert_to: :date },
        { name: :disposition_first_posted_date, value: [:protocolSection, :statusModule, :dispFirstPostDateStruct, :date], convert_to: :date },
        { name: :disposition_first_posted_date_type, value: [:protocolSection, :statusModule, :dispFirstPostDateStruct, :type] },
        { name: :last_update_submitted_date, value: [:protocolSection, :statusModule, :lastUpdateSubmitDate], convert_to: :date },
        { name: :last_update_submitted_qc_date, value: [:protocolSection, :statusModule, :lastUpdateSubmitDate], convert_to: :date },
        { name: :last_update_posted_date, value: [:protocolSection, :statusModule, :lastUpdatePostDateStruct, :date], convert_to: :date },
        { name: :last_update_posted_date_type, value: [:protocolSection, :statusModule, :lastUpdatePostDateStruct, :type] },
        { name: :start_month_year, value: [:protocolSection, :statusModule, :startDateStruct, :date] },
        { name: :start_date_type, value: [:protocolSection, :statusModule, :startDateStruct, :type] },
        { name: :start_date, value: [:protocolSection, :statusModule, :startDateStruct, :date], convert_to: :date },
        { name: :verification_month_year, value: [:protocolSection, :statusModule, :statusVerifiedDate] },
        { name: :verification_date, value: [:protocolSection, :statusModule, :statusVerifiedDate], convert_to: :date },
        { name: :completion_month_year, value: [:protocolSection, :statusModule, :completionDateStruct, :date] },
        { name: :completion_date_type, value: [:protocolSection, :statusModule, :completionDateStruct, :type] },
        { name: :completion_date, value: [:protocolSection, :statusModule, :completionDateStruct, :date], convert_to: :date },
        { name: :primary_completion_month_year, value: [:protocolSection, :statusModule, :primaryCompletionDateStruct, :date] },
        { name: :primary_completion_date_type, value: [:protocolSection, :statusModule, :primaryCompletionDateStruct, :type] },
        { name: :primary_completion_date, value: [:protocolSection, :statusModule, :primaryCompletionDateStruct, :date], convert_to: :date },
        { name: :baseline_population, value: [:resultsSection, :baselineCharacteristicsModule, :populationDescription] },
        { name: :brief_title, value: [:protocolSection, :identificationModule, :briefTitle] },
        { name: :official_title, value: [:protocolSection, :identificationModule, :officialTitle] },
        { name: :acronym, value: [:protocolSection, :identificationModule, :acronym] },
        { name: :overall_status, value: [:protocolSection, :statusModule, :overallStatus] },
        { name: :last_known_status, value: [:protocolSection, :statusModule, :lastKnownStatus] },
        { name: :why_stopped, value: [:protocolSection, :statusModule, :whyStopped] },
        { name: :delayed_posting, value: [:protocolSection, :statusModule, :delayedPosting] },
        { name: :phase, value: [:protocolSection, :designModule, :phases], convert_to: ->(val) { val&.join('/') } },
        { name: :enrollment, value: [:protocolSection, :designModule, :enrollmentInfo, :count] },
        { name: :enrollment_type, value: [:protocolSection, :designModule, :enrollmentInfo, :type] },
        { name: :source, value: [:protocolSection, :identificationModule, :organization, :fullName] },
        { name: :source_class, value: [:protocolSection, :identificationModule, :organization, :class] },
        { name: :limitations_and_caveats, value: [:resultsSection, :moreInfoModule, :limitationsAndCaveats, :description] },
        { name: :number_of_arms, value: :protocolSection, convert_to: ->(val) { val&.dig('designModule','studyType') =~ /interventional/i ? val&.dig('armsInterventionsModule','armGroups')&.count : nil } },
        { name: :number_of_groups, value: :protocolSection, convert_to: ->(val) { val&.dig('designModule','studyType') =~ /interventional/i ? nil : val&.dig('armsInterventionsModule','armGroups')&.count } },
        { name: :target_duration, value: [:protocolSection, :designModule, :targetDuration] },
        { name: :study_type, value: [:protocolSection, :designModule, :studyType] },
        { name: :patient_registry, value: [:protocolSection, :designModule, :patientRegistry] },
        { name: :has_expanded_access, value: [:protocolSection, :statusModule, :expandedAccessInfo, :hasExpandedAccess] },
        { name: :expanded_access_nctid, value: [:protocolSection, :statusModule, :expandedAccessInfo, :nctId] },
        { name: :expanded_access_status_for_nctid, value: [:protocolSection, :statusModule, :expandedAccessInfo, :statusForNctId] },
        { name: :expanded_access_type_individual, value: [:protocolSection, :designModule, :expandedAccessTypes, :individual] },
        { name: :expanded_access_type_intermediate, value: [:protocolSection, :designModule, :expandedAccessTypes, :intermediate] },
        { name: :expanded_access_type_treatment, value: [:protocolSection, :designModule, :expandedAccessTypes, :treatment] },
        { name: :has_dmc, value: [:protocolSection, :oversightModule, :oversightHasDmc] },
        { name: :is_fda_regulated_drug, value: [:protocolSection, :oversightModule, :isFdaRegulatedDrug] },
        { name: :is_fda_regulated_device, value: [:protocolSection, :oversightModule, :isFdaRegulatedDevice] },
        { name: :is_unapproved_device, value: [:protocolSection, :oversightModule, :isUnapprovedDevice] },
        { name: :is_ppsd, value: [:protocolSection, :oversightModule, :isPpsd] },
        { name: :is_us_export, value: [:protocolSection, :oversightModule, :isUsExport] },
        { name: :fdaaa801_violation, value: [:protocolSection, :oversightModule, :fdaaa801Violation] },
        { name: :biospec_retention, value: [:protocolSection, :designModule, :bioSpec, :retention] },
        { name: :biospec_description, value: [:protocolSection, :designModule, :bioSpec, :description] },
        { name: :plan_to_share_ipd, value: [:protocolSection, :ipdSharingStatementModule, :ipdSharing] },
        { name: :plan_to_share_ipd_description, value: [:protocolSection, :ipdSharingStatementModule, :description] },
        { name: :ipd_time_frame, value: [:protocolSection, :ipdSharingStatementModule, :timeFrame] },
        { name: :ipd_access_criteria, value: [:protocolSection, :ipdSharingStatementModule, :accessCriteria] },
        { name: :ipd_url, value: [:protocolSection, :ipdSharingStatementModule, :url] },
        { name: :baseline_type_units_analyzed, value: [:resultsSection, :baselineCharacteristicsModule, :typeUnitsAnalyzed] }
      ]
    }
  end
end
