module ClinicalTrials
  class Indexer

    def self.create_indexes
      Study.__elasticsearch__.delete_index!
      Study.__elasticsearch__.create_index!
      Study.__elasticsearch__.import
    end

  end
end
