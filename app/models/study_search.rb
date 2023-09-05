# frozen_string_literal: true

require 'csv'
require 'open-uri'
class StudySearch < ApplicationRecord
  has_many :search_results, dependent: :destroy
  validates :grouping, uniqueness: { scope: :query }

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
