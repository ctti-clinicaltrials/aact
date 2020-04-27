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
    study_nct_id = study.nct_id
    id_values = study.id_information.pluck(:id_value).join('|')
    sponsors = study.sponsors
    grouped = sponsors.group_by(&:lead_or_collaborator)
    puts grouped
    lead = grouped['lead'].first
    collaborators = grouped['collaborator']
    collab_names = collaborators.map{|collab| "#{collab.name}[#{collab.agency_class}]"}.join('|') if collaborators
    interventions = study.interventions
    intervention_name_type = interventions.map{|intervention| "#{intervention.intervention_type}: #{intervention.name}"}.join('|') if interventions
    intervention_details = interventions.map{|intervention| "#{intervention.intervention_type}:#{intervention.name}:#{intervention.description}"}.join('|') if interventions
    design_groups = study.design_groups
    arm_details = design_groups.map{|design_group| "#{design_group.group_type}:#{design_group.title}:#{design_group.description}"}.join('|') if design_groups

    [
      study_nct_id, #nct_id
      study.brief_title, #title
      study.acronym, #acronym
      id_values, #other_ids
      "https://ClinicalTrials.gov/show/#{study_nct_id}", #url
      study.overall_status, #status
      study.why_stopped, #why_stopped
      hqc_query(study), #hqc
      study.has_dmc, #has_dmc
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
    official_title = study.official_title =~ /#{terms.join('|')}/
    return true if official_title

    brief_title = study.brief_title =~ /#{terms.join('|')}/
    return true if brief_title

    keywords = study.keywords.where(name: terms)
    return true unless keywords.empty?

    interventions = study.interventions.where(name: terms)
    return true unless interventions.empty?

    design_groups = study.design_groups.where(title: terms)
    return true unless design_groups.empty?

    false
  end
end

