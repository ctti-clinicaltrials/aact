require 'rss'
require 'uri'
class Category < ActiveRecord::Base


  def self.fetch_study_ids
    @days_back ||= 14
    @condition ||= 'COVID-19'

    begin
      retries ||= 0
      puts "try ##{ retries }"
      url = "https://clinicaltrials.gov/ct2/results/rss.xml?rcv_d=&lup_d=#{@days_back}&sel_rss=mod14&cond=#{@condition}&count=10000"
      feed = RSS::Parser.parse(url, false)
      feed.items.map(&:guid).map(&:content)
    rescue Exception => e
      if (retries += 1) < 6
        puts "Failed: #{url}.  trying again..."
        puts "Error: #{e}"
        retry
      else #give up & return empty array
        []
      end
    end
  end

  def self.load_update(params={})
    @days_back = params[:days_back] ? params[:days_back] : 14
    @condition = params[:condition] ? params[:condition] : 'COVID-19'
    covid_nct_ids = fetch_study_ids
    
    
    covid_nct_ids.each do |covid_nct_id|
      begin
        category = Category.find_by(nct_id: covid_nct_id, name: 'COVID-19')
        category ||= Category.new(nct_id: covid_nct_id)
        category.name = 'COVID-19'
        category.last_modified = Time.zone.now
        category.save
      rescue Exception => e
        puts "Failed: #{covid_nct_id}"
        puts "Error: #{e}"
        next
      end
    end
  end

  def self.study_values(study)
    # sleep 3
    study_nct_id = study.nct_id
    id_values = study.id_information.pluck(:id_value).join('|')
    sponsors = study.sponsors
    grouped = sponsors.group_by(&:lead_or_collaborator)
    puts grouped
    lead = grouped['lead'].first
    collaborators = grouped['collaborator']
    collab_names = collaborators.map{|collab| "#{collab.name}[#{collab.agency_class}]"}.join('|') if collaborators
    interventions = study.interventions
    intervention_name_type = []
    intervention_details = []

    interventions.each do |intervention| 
      intervention_name_type << "#{intervention.intervention_type || 'N/A'}: #{intervention.name}"
      intervention_details << "#{intervention.intervention_type || 'N/A'}:#{intervention.name}:#{intervention.description}"
    end
    intervention_name_type = intervention_name_type.join('|')
    intervention_details = intervention_details.join('|')

    design_groups = study.design_groups
    arm_details = []
    arm_intervention_details = []
    design_groups.each do |design_group| 
      arm_details << "#{design_group.group_type || 'N/A'}:#{design_group.title}:#{design_group.description}"
      interventions = design_group.interventions
      interventions.each do |intervention|
        arm_intervention_details << "#{design_group.group_type || 'N/A'}[#{design_group.title}]:#{intervention.intervention_type}[#{intervention.name}]"
      end
    end
      
    arm_details = arm_details.join('|')
    arm_intervention_details = arm_intervention_details.join('|')

    facilities = study.facilities
    us_facility = facilities.find_by(country: ['USA', 'US', 'United States of America', 'United States', 'America'])

    design = study.design
    if design
      primary_purpose = design.primary_purpose
      intervention_model = design.intervention_model
      observational_model = design.observational_model 
      allocation = design.allocation 
      masking = design.masking
      subject_masked = design.subject_masked ? 1 : 0 
      caregiver_masked = design.caregiver_masked ? 1 : 0
      investigator_masked = design.investigator_masked ? 1 : 0 
      outcomes_assessor_masked = design.outcomes_assessor_masked ? 1 : 0
    end

    eligibility = study.eligibility
    if eligibility
      minimum_age = eligibility.minimum_age
      maximum_age = eligibility.maximum_age
      gender = eligibility.gender
      gender_based = eligibility.gender_based
      gender_description = eligibility.gender_description
      healthy_volunteers = eligibility.healthy_volunteers
      population = eligibility.population
      @criteria = eligibility.criteria
    end

    adaptive_protocol = single_term_query('adaptive', study) ? 1 : 0
    master_protocol = single_term_query('master', study) ? 1 : 0
    platform_protocol = single_term_query('platform', study) ? 1 : 0
    umbrella_protocol = single_term_query('umbrella', study) ? 1 : 0
    basket_protocol = single_term_query('basket', study) ? 1 : 0

    
    # "11Apr2016"
    # byebug 
    [
      study_nct_id, #nct_id
      study.brief_title, #title
      study.acronym, #acronym
      id_values, #other_ids
      "https://ClinicalTrials.gov/show/#{study_nct_id}", #url
      study.overall_status, #status
      study.why_stopped, #why_stopped
      hqc_query(study) ? 1 : 0, #hqc
      study.has_dmc ? 1 : 0, #has_dmc
      sponsors.pluck(:agency_class).uniq.join('|'), #funded_bys
      sponsors.pluck(:name).join('|'), #sponsor_collaborators
      lead ? "#{lead.name}[#{lead.agency_class}]" : nil, #lead_sponsor
      collab_names, #collaborators
      study.study_type, #study_type
      study.phase.try(:split, '/').try(:join, '|'), #phases
      study.enrollment, #enrollment
      study.brief_summary.try(:description), #brief_summary
      study.detailed_description.try(:description), #detailed_description
      study.conditions.pluck(:name).join('|'), #conditions
      study.keywords.pluck(:name).join('|'), #keywords
      intervention_name_type, #interventions
      intervention_details, #intervention_details
      arm_details, #arm_datails
      arm_intervention_details, #arm_intervention_details
      study.design_outcomes.pluck(:measure).join('|'), #outcome_measures
      study.start_date, #start_date
      study.primary_completion_date, #primary_completion_date
      study.completion_date, #completion_date 
      study.study_first_posted_date, #first_posted
      study.results_first_posted_date, #results_first_posted
      study.last_update_posted_date, #last_update_posted
      study.nlm_download_date_description, #nlm_download_date
      study.study_first_submitted_date, #study_first_submitted_date
      study.has_expanded_access ? 1 : 0, #has_expanded_access
      study.is_fda_regulated_drug ? 1 : 0, #is_fda_regulated_drug
      study.is_fda_regulated_device ? 1 : 0, #is_fda_regulated_device
      study.is_unapproved_device ? 1 : 0, #is_unapproved_device
      locations(facilities), #locations
      facilities.count, #number_of_facilities
      us_facility ? 1 : 0, #has_us_facility
      facilities.count == 1 ? 1 : 0, #has_single_facility
      study_design(design), #study_design
      study.number_of_arms, #number_of_arms
      study.number_of_groups, #number_of_groups
      primary_purpose, #primary_purpose
      intervention_model, #intervention_model
      observational_model, #observational_model
      allocation, #allocation
      masking, #masking
      subject_masked, #subject_masked
      caregiver_masked, #caregiver_masked
      investigator_masked, #investigator_masked
      outcomes_assessor_masked, #outcomes_assessor_masked
      adaptive_protocol, #adaptive_protocol
      master_protocol, #master_protocol
      platform_protocol, #platform_protocol
      umbrella_protocol, #umbrella_protocol
      basket_protocol, #basket_protocol
      minimum_age, #minimum_agey
      maximum_age, #maximum_agey
      gender, #gender
      gender_based, #gender_based
      gender_description, #gender_description
      healthy_volunteers, #healthy_volunteers
      population, #population
      @criteria, #criteria
      study_documents(study), #study_documents
    ]
    
  end

  def self.test
    studies = Study.all
    studies.each do |study| 
      puts study_values(study)
    end
  end

  def self.hqc_query(study)
    terms = %w[ hydroxychloroquine plaquenil hidroxicloroquina quineprox ]
    official_title = study.official_title =~ /#{terms.join('|')}/i
    return true if official_title

    brief_title = study.brief_title =~ /#{terms.join('|')}/i
    return true if brief_title

    sql = terms.map{ 'name ILIKE ?'}.join(' OR ')
    keywords = study.keywords.where(sql, *terms)
    return true unless keywords.empty?

    interventions = study.interventions.where(sql, *terms)
    return true unless interventions.empty?

    sql = terms.map{ 'title ILIKE ?'}.join(' OR ')
    design_groups = study.design_groups.where(sql, *terms)
    return true unless design_groups.empty?

    false
  end

  def self.locations(facilities)
    locations = []
    facilities.each do |facility|
      string = "#{facility.name}"
      string += ", #{facility.city}" unless facility.city.empty? || facility.city.nil?
      string += ", #{facility.state}" unless facility.state.empty? || facility.state.nil?
      string += ", #{facility.country}" unless facility.country.empty? || facility.country.nil?

      locations << string
    end
      # "#{facility.name}, #{facility.city}, #{facility.state}, #{facility.country}"
    locations.join('|')
  end

  def self.study_design(design)
    return unless design

    who_masked = []
    who_masked << 'Participant' if design.subject_masked
    who_masked << 'Caregiver' if design.caregiver_masked
    who_masked << 'Investigator' if design.investigator_masked
    who_masked << 'Outcomes Assessor' if design.outcomes_assessor_masked

    who_masked = who_masked.empty? ? '' : "(#{who_masked.join(', ')})"

    study_design = []
    study_design << "Allocation: #{design.allocation}" if design.allocation
    study_design << "Intervention Model: #{design.intervention_model}" if design.intervention_model
    study_design << "Observational Model: #{design.observational_model}" if design.observational_model
    study_design << "Primary Purpose: #{design.primary_purpose}" if design.primary_purpose
    study_design << "Time Perspective: #{design.time_perspective}" if design.time_perspective
    study_design << "Masked: #{design.masking} #{who_masked}".squish if design.masking

    study_design.join('|')
  end

  def self.single_term_query(term, study)
    official_title = study.official_title =~ /#{term}/i
    return true if official_title

    brief_title = study.brief_title =~ /#{term}/
    return true if brief_title

    brief_summary = study.brief_summary.try(:description) =~ /#{term}/i
    return true if brief_summary

    detailed_description = study.detailed_description.try(:description) =~ /#{term}/i
    return true if detailed_description

    eligibility_criteria = @criteria =~ /#{term}/i if @criteria
    return true if eligibility_criteria
  end

  def self.study_documents(study)
    provided_documents = study.provided_documents
    provided_documents.map{|provided_document| "#{provided_document.document_type}, #{provided_document.url}"}.join('|')
  end
end

