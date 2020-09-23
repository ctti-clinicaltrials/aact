require 'csv'
class Search < ActiveRecord::Base
  validates :grouping, uniqueness: {scope: :query}
  
  def self.populate_database
    find_or_create_by(save_tsv: true, grouping: 'covid-19', query: 'covid-19')
    path = "#{Rails.root}/app/documents/LeadingCausesDeath_terms.csv"
    file =  open(path, "r") { |io| io.read.encode("UTF-8", invalid: :replace) }
    query_data = CSV.parse(file, headers: true)
    query_data.each do |line|
      find_or_create_by(save_tsv: false, grouping: line[0], query: line[3])
    end
  end
end
