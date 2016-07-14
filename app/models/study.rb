require 'csv'
class Study < ActiveRecord::Base
  attr_accessor :xml

  scope :interventional,  -> {where(study_type: 'Interventional')}
  scope :observational,   -> {where(study_type: 'Observational')}
  scope :current, -> { where("first_received_date >= '2007/10/01' and study_type='Interventional'") }

  def self.current_interventional
    self.interventional and self.current
  end

  self.primary_key = 'nct_id'
  has_many :reviews,               :foreign_key => 'nct_id', dependent: :destroy

  has_one  :brief_summary,         :foreign_key => 'nct_id', dependent: :destroy
  has_one  :design,                :foreign_key => 'nct_id', dependent: :destroy
  has_one  :detailed_description,  :foreign_key => 'nct_id', dependent: :destroy
  has_one  :eligibility,           :foreign_key => 'nct_id', dependent: :destroy
  has_one  :participant_flow,      :foreign_key => 'nct_id', dependent: :destroy
  has_one  :result_detail,         :foreign_key => 'nct_id', dependent: :destroy
  has_one  :derived_value,         :foreign_key => 'nct_id', dependent: :destroy
  has_one  :study_xml_record,      :foreign_key => 'nct_id'

  has_many :pma_mappings,          :foreign_key => 'nct_id'
  has_many :pma_records,           :foreign_key => 'nct_id', dependent: :destroy
  has_many :expected_groups,       :foreign_key => 'nct_id', dependent: :destroy
  has_many :expected_outcomes,     :foreign_key => 'nct_id', dependent: :destroy
  has_many :groups,                :foreign_key => 'nct_id', dependent: :destroy
  has_many :outcomes,              :foreign_key => 'nct_id', dependent: :destroy
  has_many :baseline_measures,     :foreign_key => 'nct_id', dependent: :destroy
  has_many :browse_conditions,     :foreign_key => 'nct_id', dependent: :destroy
  has_many :browse_interventions,  :foreign_key => 'nct_id', dependent: :destroy
  has_many :conditions,            :foreign_key => 'nct_id', dependent: :destroy
  has_many :drop_withdrawals,      :foreign_key => 'nct_id', dependent: :destroy
  has_many :facilities,            :foreign_key => 'nct_id', dependent: :destroy
  has_many :interventions,         :foreign_key => 'nct_id', dependent: :destroy
  has_many :keywords,              :foreign_key => 'nct_id', dependent: :destroy
  has_many :links,                 :foreign_key => 'nct_id', dependent: :destroy
  has_many :milestones,            :foreign_key => 'nct_id', dependent: :destroy
  has_many :location_countries,    :foreign_key => 'nct_id', dependent: :destroy
  has_many :outcome_measures,      :foreign_key => 'nct_id', dependent: :destroy
  has_many :overall_officials,     :foreign_key => 'nct_id', dependent: :destroy
  has_many :oversight_authorities, :foreign_key => 'nct_id', dependent: :destroy
  has_many :reported_events,       :foreign_key => 'nct_id', dependent: :destroy
  has_many :responsible_parties,   :foreign_key => 'nct_id', dependent: :destroy
  has_many :result_agreements,     :foreign_key => 'nct_id', dependent: :destroy
  has_many :result_contacts,       :foreign_key => 'nct_id', dependent: :destroy
  has_many :secondary_ids,         :foreign_key => 'nct_id', dependent: :destroy
  has_many :sponsors,              :foreign_key => 'nct_id', dependent: :destroy
  has_many :references,            :foreign_key => 'nct_id', dependent: :destroy

  scope :started_between, lambda {|sdate, edate| where("start_date >= ? AND created_at <= ?", sdate, edate )}
  scope :changed_since,   lambda {|cdate| where("last_changed_date >= ?", cdate )}
  scope :completed_since, lambda {|cdate| where("completion_date >= ?", cdate )}
  scope :sponsored_by,    lambda {|agency| joins(:sponsors).where("sponsors.agency LIKE ?", "#{agency}%")}

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

  def self.create_derived_values
    # TODO once we figure out the nightly differential,
    # change this method to only update derived values for
    # studies that have changed.

    load_event = ClinicalTrials::LoadEvent.create(
      event_type: 'populate_studies'
    )

    batch_size = 500
    ids = Study.pluck(:nct_id)

    ids.each_slice(batch_size) do |batch|
      batch.each do |id|
        study = Study.find_by(nct_id: id)
        DerivedValue.new.create_from(study).save
      end
    end

    load_event.complete
  end

  def create
    update(attribs)
    ExpectedGroup.create_all_from(opts)
    Group.create_all_from(opts)
    Outcome.create_all_from(opts.merge(:groups=>self.groups))
    Milestone.create_all_from(opts.merge(:groups=>self.groups))
    DropWithdrawal.create_all_from(opts.merge(:groups=>self.groups))
    DetailedDescription.new.create_from(opts).save
    Design.new.create_from(opts).save
    BriefSummary.new.create_from(opts).save
    Eligibility.new.create_from(opts).save
    ParticipantFlow.new.create_from(opts).save
    ResultDetail.new.create_from(opts).save
    BaselineMeasure.create_all_from(opts)
    BrowseCondition.create_all_from(opts)
    BrowseIntervention.create_all_from(opts)
    Condition.create_all_from(opts)
    Facility.create_all_from(opts)
    Intervention.create_all_from(opts)
    Keyword.create_all_from(opts)
    Link.create_all_from(opts)
    LocationCountry.create_all_from(opts)
    OversightAuthority.create_all_from(opts)
    OverallOfficial.create_all_from(opts)
    ExpectedOutcome.create_all_from(opts)
    ReportedEvent.create_all_from(opts)
    ResponsibleParty.create_all_from(opts)
    ResultAgreement.create_all_from(opts)
    ResultContact.create_all_from(opts)
    SecondaryId.create_all_from(opts)
    Reference.create_all_from(opts)
    Sponsor.create_all_from(opts)
    # DerivedValue.new.create_from(self).save
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

  def lead_sponsor
    # sponsors.select{|s|s.sponsor_type=='lead'}.first
    sponsors.find_by(sponsor_type: 'lead')
  end

  def collaborators
    # sponsors.select{|s|s.sponsor_type=='collaborator'}
    sponsors.where(sponsor_type: 'collaborator')
  end

  def lead_sponsor_name
    lead_sponsor.try(:agency)
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

  def recruitment_details
    result_detail.try(:recruitment_details)
  end

  def pre_assignment_details
    result_detail.try(:pre_assignment_details)
  end

  def attribs
    {
      :start_date => get_date(get('start_date')),
      :first_received_date => get_date(get('firstreceived_date')),
      :verification_date => get_date(get('verification_date')),
      :last_changed_date => get_date(get('lastchanged_date')),
      :primary_completion_date => get_date(get('primary_completion_date')),
      :completion_date => get_date(get('completion_date')),
      :first_received_results_date => get_date(get('firstreceived_results_date')),

      :start_date_str => get('start_date'),
      :first_received_date_str => get('firstreceived_date'),
      :verification_date_str => get('verification_date'),
      :last_changed_date_str => get('lastchanged_date'),
      :primary_completion_date_str => get('primary_completion_date'),
      :completion_date_str => get('completion_date'),
      :first_received_results_date_str => get('firstreceived_results_date'),
      :download_date_str => xml.xpath('//download_date').text,

      :org_study_id => xml.xpath('//org_study_id').text,
      :acronym =>get('acronym'),
      :number_of_arms => get('number_of_arms'),
      :number_of_groups =>get('number_of_groups'),
      :source => get('study_source'),
      :brief_title  => get('brief_title') ,
      :official_title => get('official_title'),
      :overall_status => get('overall_status'),
      :phase => get('phase'),
      :target_duration => get('target_duration'),
      :enrollment => get('enrollment'),
      :biospec_description =>get_text('biospec_descr').strip,

      :primary_completion_date_type => get_type('primary_completion_date'),
      :completion_date_type => get_type('completion_date'),
      :enrollment_type => get_type('enrollment'),
      :study_type => get('study_type'),
      :biospec_retention =>get('biospec_retention').strip,
      :limitations_and_caveats  =>get('limitations_and_caveats'),

      :is_section_801 => get_boolean('is_section_801'),
      :is_fda_regulated => get_boolean('is_fda_regulated'),
      :has_expanded_access => get_boolean('has_expanded_access'),
      :has_dmc => get_boolean('has_dmc'),
      :why_stopped =>get('why_stopped').strip,
      #:delivery_mechanism =>delivery_mechanism,

    }
  end

  def get_groups(opts)
    self.groups=Group.create_all_from(opts)
  end

  def get(label)
    xml.xpath('//clinical_study').xpath("#{label}").text
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
    val=xml.xpath("//#{label}").try(:text)
    val.downcase=='yes'||val.downcase=='y'||val.downcase=='true' if !val.blank?
  end

  def get_date(str)
    Date.parse(str) if !str.blank?
  end

  def lead_sponsor
    #TODO  May be multiple
    sponsors.each{|s|return s if s.sponsor_type=='lead'}
  end

  def average_rating
    if reviews.size==0
      0
    else
      reviews.average(:rating).round(2)
    end
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

end
