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
      find_or_create_by(save_tsv: false, grouping: line[0], query: line[3], name: line[3], beta_api: false)
    end
  end

  def self.make_covid_search
    find_or_create_by(save_tsv: true, grouping: 'covid-19', query: 'covid-19', name: 'covid-19', beta_api: false)
  end

  def self.make_funder_search
    string = 'AREA[LocationCountry] EXPAND[None] COVER[FullMatch] "United States" AND AREA[LeadSponsorClass] EXPAND[None] COVER[FullMatch] "OTHER" AND AREA[FunderTypeSearch] EXPAND[None] NOT ( RANGE[AMBIG, NIH] OR RANGE[OTHER_GOV, UNKNOWN] )'
    find_or_create_by(save_tsv: false, grouping: 'funder_type', query: string, name: 'US no external funding', beta_api: true)
  end

  def load_update(days_back=2)
    collected_nct_ids = fetch_study_ids(days_back)
    
    collected_nct_ids.each do |collected_nct_id|
      begin
        found_search_result = SearchResult.find_by(nct_id: collected_nct_id, name: [name, name.underscore], grouping: [grouping, ''])
        found_search_result.update(grouping: name) if found_search_result && found_search_result.grouping.empty?
        found_search_result.update(study_search_id: id) if found_search_result && found_search_result.study_search_id.nil?
        found_search_result ||= search_results.create(
                                      nct_id: collected_nct_id,
                                      name: name,
                                      grouping: grouping,
                                    )
      rescue Exception => e
        puts "Failed: #{collected_nct_id}"
        puts "Error: #{e}"
        next
      end
    end
    SearchResult.make_tsv(name) if save_tsv
  end

  def self.execute(days_back=2)
    # days_back = days_back || (Date.today - Date.parse('2013-01-01')).to_i
    queries = all
    queries.each do |query|
      query.load_update(days_back)
    end
  end

  def fetch_study_ids(days_back=2)
    return StudySearch.collected_nct_ids(query) if beta_api

    Util::RssReader.new(days_back: days_back, condition: query).get_changed_nct_ids
  end

  def self.json_data(url)
    # "https://clinicaltrials.gov/api/query/full_studies?expr=#{query}&min_rnk=1&max_rnk=100&fmt=json"
    url = URI.escape(url)
    JSON.parse(open(url).read)
  end
  

  def self.time_range(days_back)
    return '' unless days_back

    date = (Date.current - days_back.to_i).strftime('%m/%d/%Y')
    "AREA[LastUpdatePostDate]RANGE[#{date},%20MAX]"
  end

  def self.collected_nct_ids(search_constraints='covid-19')
    collection = []
    first_batch = json_data("https://clinicaltrials.gov/api/query/full_studies?expr=#{search_constraints}&min_rnk=1&max_rnk=100&fmt=json")
    # collection << parse_ids(first_batch.dig('FullStudiesResponse', 'FullStudies'))
    total_studies_found = first_batch['FullStudiesResponse']['NStudiesFound']
    limit = (total_studies_found/100.0).ceil
    # studies must be retrieved in batches of 99,
    min = 1
    max = 100
    
    for x in 1..limit
      collection += fetch_beta_nct_ids(search_constraints, min, max)
      puts collection.size
      min += 100
      max += 100
    end
    collection
  end

  def self.fetch_beta_nct_ids(search_constraints, min=1, max=100)
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
