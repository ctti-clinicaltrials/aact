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
    id_values = study.id_information.pluck(:id_values).join('|')
    study_nct_id = study.nct_id
    [
      study_nct_id, #nct_id
      study.brief_title, #title
      study.acronym, #acronym
      id_values, #other_ids
      "https://ClinicalTrials.gov/show/#{study_nct_id}", #url
      "https://ClinicalTrials.gov/show/#{study_nct_id}", #Hyperlink
      study.overall_status, #status
      study.why_stopped, #why_stopped
      , #hqc
    ]
    
  end

  def self.hqc_query(study)
    terms = [
              'hydroxychloroquine',
              'plaquenil',
              'hidroxicloroquina',
              'quineprox'
            ]

    
  end
end

