class String
  def is_missing_the_day?
    # use this method on string representations of dates.  If only one space in the string, then the day is not provided.
    (count ' ') == 1
  end
end

class Study < ActiveRecord::Base

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
  self.primary_key = 'nct_id'

  has_one  :brief_summary,         :foreign_key => 'nct_id', :dependent => :delete
  has_one  :design,                :foreign_key => 'nct_id', :dependent => :delete
  has_one  :detailed_description,  :foreign_key => 'nct_id', :dependent => :delete
  has_one  :eligibility,           :foreign_key => 'nct_id', :dependent => :delete
  has_one  :participant_flow,      :foreign_key => 'nct_id', :dependent => :delete
  has_one  :calculated_value,      :foreign_key => 'nct_id', :dependent => :delete
  has_one  :study_xml_record,      :foreign_key => 'nct_id'

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
  has_many :keywords,              :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :links,                 :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :milestones,            :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :outcomes,              :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :outcome_analysis_groups, :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :outcome_analyses,      :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :outcome_measurements,  :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :overall_officials,     :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :pending_results,       :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :references,            :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :reported_events,       :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :responsible_parties,   :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :result_agreements,     :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :result_contacts,       :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :result_groups,         :foreign_key => 'nct_id', :dependent => :delete_all
  has_many :sponsors,              :foreign_key => 'nct_id', :dependent => :delete_all
  accepts_nested_attributes_for :outcomes

  def initialize(hash)
    super
    @xml=hash[:xml]
    self.nct_id=hash[:nct_id]
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

  def create
    ActiveRecord::Base.logger=nil
    s=Study.where('nct_id=?',nct_id).first
    s.try(:destroy)
    update(attribs)
    groups=DesignGroup.create_all_from(opts)
    Intervention.create_all_from(opts.merge(:design_groups=>groups))
    DetailedDescription.new.create_from(opts).try(:save)
    Design.new.create_from(opts).try(:save)
    BriefSummary.new.create_from(opts).try(:save)
    Eligibility.new.create_from(opts).save
    ParticipantFlow.new.create_from(opts).try(:save)

    BaselineMeasurement.create_all_from(opts)
    BrowseCondition.create_all_from(opts)
    BrowseIntervention.create_all_from(opts)
    CentralContact.create_all_from(opts)
    Condition.create_all_from(opts)
    Country.create_all_from(opts)
    Document.create_all_from(opts)
    Facility.create_all_from(opts)
    IdInformation.create_all_from(opts)
    Keyword.create_all_from(opts)
    Link.create_all_from(opts)
    Milestone.create_all_from(opts)
    Outcome.create_all_from(opts)
    OverallOfficial.create_all_from(opts)
    DesignOutcome.create_all_from(opts)
    PendingResult.create_all_from(opts)
    ReportedEvent.create_all_from(opts)
    ResponsibleParty.create_all_from(opts)
    ResultAgreement.create_all_from(opts)
    ResultContact.create_all_from(opts)
    Reference.create_all_from(opts)
    Sponsor.create_all_from(opts)
    # During full load, indexes are dropped. Populating CalculatedValues requires several db queries - so they're scanned and very slow.
    # Populate the CalculatedValues after the indexes have been recreated after the full load completes.
    #CalculatedValue.new.create_from(self).save
    self
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

  def attribs
    {
      :start_month_year              => get('start_date'),
      :verification_month_year       => get('verification_date'),
      :completion_month_year         => get('completion_date'),
      :primary_completion_month_year => get('primary_completion_date'),

      :start_date                    =>  convert_date('start_date'),
      :verification_date             =>  convert_date('verification_date'),
      :completion_date               =>  convert_date('completion_date'),
      :primary_completion_date       =>  convert_date('primary_completion_date'),

      :study_first_submitted_qc_date        =>  get('study_first_submitted_qc').try(:to_date),
      :study_first_posted_date              =>  get('study_first_posted').try(:to_date),
      :results_first_submitted_qc_date      =>  get('results_first_submitted_qc').try(:to_date),
      :results_first_posted_date            =>  get('results_first_posted').try(:to_date),
      :disposition_first_submitted_qc_date  =>  get('disposition_first_submitted_qc').try(:to_date),
      :disposition_first_posted_date        =>  get('disposition_first_posted').try(:to_date),
      :last_update_submitted_qc_date        =>  get('last_update_submitted_qc').try(:to_date),
      :last_update_posted_date              =>  get('last_update_posted').try(:to_date),

      # the previous have been replaced with:
      :study_first_submitted_date => get_date(get('study_first_submitted')),
      :results_first_submitted_date => get_date(get('results_first_submitted')),
      :disposition_first_submitted_date => get_date(get('disposition_first_submitted')),
      :last_update_submitted_date => get_date(get('last_update_submitted')),

      :nlm_download_date_description => xml.xpath('//download_date').text,
      :acronym =>get('acronym'),
      :baseline_population  =>xml.xpath('//baseline/population').try(:text),
      :number_of_arms => get('number_of_arms'),
      :number_of_groups =>get('number_of_groups'),
      :source => get('source'),
      :brief_title  => get('brief_title') ,
      :official_title => get('official_title'),
      :overall_status => get('overall_status'),
      :last_known_status => get('last_known_status'),
      :phase => get('phase'),
      :target_duration => get('target_duration'),
      :enrollment => get('enrollment'),
      :biospec_description =>get_text('biospec_descr'),

      :start_date_type                           => get_type('start_date'),
      :primary_completion_date_type              => get_type('primary_completion_date'),
      :completion_date_type                      => get_type('completion_date'),
      :study_first_posted_date_type              => get_type('study_first_posted'),
      :results_first_posted_date_type            => get_type('results_first_posted'),
      :disposition_first_posted_date_type        => get_type('disposition_first_posted'),
      :last_update_posted_date_type              => get_type('last_update_posted'),
      :enrollment_type                           => get_type('enrollment'),

      :study_type                                => get('study_type'),
      :biospec_retention =>get('biospec_retention'),
      :limitations_and_caveats  =>xml.xpath('//limitations_and_caveats').text,
      :is_fda_regulated_drug =>get_boolean('//is_fda_regulated_drug'),
      :is_fda_regulated_device =>get_boolean('//is_fda_regulated_device'),
      :is_unapproved_device =>get_boolean('//is_unapproved_device'),
      :is_ppsd =>get_boolean('//is_ppsd'),
      :is_us_export  =>get_boolean('//is_us_export'),
      :plan_to_share_ipd => get('patient_data/sharing_ipd'),
      :plan_to_share_ipd_description => get('patient_data/ipd_description'),
      :has_expanded_access => get_boolean('//has_expanded_access'),
      :expanded_access_type_individual => get_boolean('//expanded_access_info/expanded_access_type_individual'),
      :expanded_access_type_intermediate => get_boolean('//expanded_access_info/expanded_access_type_intermediate'),
      :expanded_access_type_treatment => get_boolean('//expanded_access_info/expanded_access_type_treatment'),
      :has_dmc => get_boolean('//has_dmc'),
      :why_stopped =>get('why_stopped')
    }
  end

  def get_groups(opts)
    self.groups=ResultGroup.create_all_from(opts)
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

end
