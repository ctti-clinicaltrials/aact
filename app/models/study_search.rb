require 'csv'
require 'open-uri'
class StudySearch < ActiveRecord::Base
  has_many :search_results, dependent: :destroy
  validates :grouping, uniqueness: {scope: :query}
  
  def self.populate_database
    make_covid_search
    make_funder_search
    make_causes_of_death_search
  end

  def self.make_causes_of_death_search
    path = "#{Rails.root}/app/documents/LeadingCausesDeath_terms.csv"
    file =  open(path, "r") { |io| io.read.encode("UTF-8", invalid: :replace) }
    query_data = CSV.parse(file, headers: true)
    query_data.each do |line|
      find_or_create_by(save_tsv: false, grouping: line[0], query: line[3], name: line[3], beta_api: true)
    end
  end

  def self.make_covid_search
    find_or_create_by(save_tsv: true, grouping: 'covid-19', query: 'covid-19', name: 'covid-19', beta_api: true)
  end

  def self.make_funder_search
    string = 'AREA[LocationCountry] EXPAND[None] COVER[FullMatch] "United States" AND AREA[LeadSponsorClass] EXPAND[None] COVER[FullMatch] "OTHER" AND AREA[FunderTypeSearch] EXPAND[None] NOT ( RANGE[AMBIG, NIH] OR RANGE[OTHER_GOV, UNKNOWN] )'
    find_or_create_by(save_tsv: false, grouping: 'funder_type', query: string, name: 'US no external funding', beta_api: true)
  end

  def load_update(days_back=2)
    # date_ranged_query = query + StudySearch.time_range(days_back)
    # collection = StudySearch.collected_nct_ids(date_ranged_query) 
    collection = StudySearch.collected_nct_ids(query) 
    total = collection.count
    collection.each do |study_nct_id|
      next unless Study.find_by(nct_id: study_nct_id)
      
      begin
        puts "#{total} #{study_nct_id}"
        found_search_result = SearchResult.find_by(nct_id: study_nct_id, name: [name, name.underscore], grouping: [grouping, ''])
        found_search_result.update(grouping: name) if found_search_result && found_search_result.grouping.empty?
        found_search_result.update(study_search_id: id) if found_search_result && found_search_result.study_search_id.nil?
        found_search_result ||= search_results.create(
                                      nct_id: study_nct_id,
                                      name: name,
                                      grouping: grouping,
                                    )
        total -= 1
      rescue Exception => e
        puts "Failed: #{study_nct_id}"
        ErrorLog.error("#{error.message} (#{error.class} #{error.backtrace}")
        Airbrake.notify(e)
        next
      end
    end
    SearchResult.make_tsv(name) if save_tsv
  end

  def self.execute(days_back=2)
    queries = all
    begin
      queries.each do |query|
        print "running query group: #{query.grouping}..."
        query.load_update(days_back)
        puts "group is done"
      end
    rescue => e
      Airbrake.notify(e)
    end
  end

  def self.json_data(url)
    # "https://clinicaltrials.gov/api/query/full_studies?expr=#{query}&min_rnk=1&max_rnk=100&fmt=json"
    begin
    url = URI.escape(url)
    JSON.parse(open(url).read)
    rescue
      nil
    end
  end
  

  def self.time_range(days_back)
    number_of_days = days_back.try(:to_i)
    number_of_days = 0 unless number_of_days

    date = (Date.current - number_of_days).strftime('%m/%d/%Y')
    "AREA[LastUpdatePostDate]RANGE[#{date},%20MAX]"
  end

  def self.collected_nct_ids(search_constraints='covid-19')
    puts "Collecting nct_ids for #{search_constraints}"
    collection = []
    first_batch = json_data("https://clinicaltrials.gov/api/query/full_studies?expr=#{search_constraints}&min_rnk=1&max_rnk=100&fmt=json")
    total_studies_found = first_batch['FullStudiesResponse']['NStudiesFound']
    limit = (total_studies_found/100.0).ceil
    countdown = total_studies_found
    # studies must be retrieved in batches of 99,
    min = 1
    max = 100
   
    for x in 1..limit
      puts "Batch Countdown: #{countdown}"
      collection += fetch_nct_ids(search_constraints, min, max)
      min += 100
      max += 100
      countdown -= 1
    end
    collection
  end

  def self.fetch_nct_ids(search_constraints, min=1, max=100)
    begin
      retries ||= 0
      url = "https://clinicaltrials.gov/api/query/full_studies?expr=#{search_constraints}&min_rnk=#{min}&max_rnk=#{max}&fmt=json"
      data = json_data(url) || {}
      data = data.dig('FullStudiesResponse', 'FullStudies')
      nct_id_array = parse_ids(data) if data
      return nct_id_array || []
  
    rescue
      retry if (retries += 1) < 6
    end
    []
  end

  def self.parse_ids(study_batch)
    return unless study_batch

    study_batch.collect{|study_data| study_data['Study']['ProtocolSection']['IdentificationModule']['NCTId'] }
  
  end 
end
