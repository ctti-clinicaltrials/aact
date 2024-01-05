class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.is_masked?(who_masked_array, query_array)
    # example who_masked array ["PARTICIPANT", "CARE_PROVIDER", "INVESTIGATOR", "OUTCOMES_ASSESSOR"]
    return unless query_array

    query_array.each do |term|
      return true if who_masked_array.try(:include?, term)
    end
    nil
  end
end
