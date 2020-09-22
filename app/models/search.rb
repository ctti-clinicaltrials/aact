class Search < ActiveRecord::Base
  def self.populate_database
    find_or_create_by(save_tsv: false, grouping: 'Malignant Neoplasms', query: 'Malignant neoplasm of lip')
    find_or_create_by(save_tsv: true, grouping: 'covid-19', query: 'covid-19')
  end
end
