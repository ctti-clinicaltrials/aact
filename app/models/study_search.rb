# frozen_string_literal: true

require 'csv'
require 'open-uri'
class StudySearch < ApplicationRecord
  has_many :search_results, dependent: :destroy
  validates :grouping, uniqueness: { scope: :query }

  # def self.populate_database
  #   make_covid_search
  #   make_funder_search
  #   make_causes_of_death_search
  # end

  # def self.make_causes_of_death_search
  #   path = "#{Rails.root}/app/documents/LeadingCausesDeath_terms.csv"
  #   file =  open(path, "r") { |io| io.read.encode("UTF-8", invalid: :replace) }
  #   query_data = CSV.parse(file, headers: true)
  #   query_data.each do |line|
  #     find_or_create_by(save_tsv: false, grouping: line[0], query: line[3], name: line[3], beta_api: true)
  #   end
  # end

  # def self.make_funder_search
  #   query = 'AREA[LocationCountry] EXPAND[None] COVER[FullMatch] "United States" AND AREA[LeadSponsorClass] EXPAND[None] COVER[FullMatch] "OTHER" AND AREA[FunderTypeSearch] EXPAND[None] NOT ( RANGE[AMBIG, NIH] OR RANGE[OTHER_GOV, UNKNOWN] )'
  #   find_or_create_by(save_tsv: false, grouping: 'funder_type', query: query, name: 'US no external funding', beta_api: true)
  # end

  # def self.make_covid_search
  #   find_or_create_by(save_tsv: true, grouping: 'covid-19', query: 'covid-19', name: 'covid-19', beta_api: true)
  # end

  def load_update
    collection = ClinicalTrialsApi.nct_ids_for(query)
    total = collection.count
    collection.each do |study_nct_id|
      next unless Study.find_by(nct_id: study_nct_id)

      begin
        Rails.logger.debug { "#{total} #{study_nct_id}" }
        search_results.find_or_create_by(nct_id: study_nct_id, name: name, grouping: grouping)
        total -= 1
      rescue StandardError => e
        Rails.logger.debug { "Failed: #{study_nct_id}" }
        ErrorLog.error("#{error.message} (#{error.class} #{error.backtrace}")
        Airbrake.notify(e)
        next
      end
    end
    SearchResult.make_tsv(name) if save_tsv
  end

  def self.execute(_days_back = 2)
    all.find_each do |query|
      Rails.logger.debug { "running query group: #{query.grouping}..." }
      query.load_update
      Rails.logger.debug 'group is done'
    end
  rescue StandardError => e
    Airbrake.notify(e)
  end
end
