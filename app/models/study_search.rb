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
    collection = ClinicalTrialsApi.nct_ids_for(query) 
    total = collection.count
    collection.each do |study_nct_id|
      next unless Study.find_by(nct_id: study_nct_id)
      
      begin
        puts "#{total} #{study_nct_id}"
        search_results.find_or_create_by(nct_id: study_nct_id, name: name, grouping: grouping)
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

  def self.parse_ids(study_batch)
    return unless study_batch

    study_batch.collect{|study_data| study_data['Study']['ProtocolSection']['IdentificationModule']['NCTId'] }
  
  end 
end
