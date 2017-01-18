module ClinicalTrials
  class Indexer

    def self.create_indexes
      Study.__elasticsearch__.delete_index!  if Study.__elasticsearch__.index_exists?
      Study.__elasticsearch__.create_index!
      Study.__elasticsearch__.import
    end

  end
end
