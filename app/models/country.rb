class Country < StudyRelationship

  # def self.mapper(json)
  #   return unless json.derived_section

  #   nct_id = json.protocol_section.dig('identificationModule', 'nctId')
  #   removed_countries = json.derived_section.dig('miscInfoModule', 'removedCountries') || []
  #   locations = json.locations_array || []
  #   return if locations.empty? && removed_countries.empty?
  
  #   countries = []
  #   collection = []
  
  #   locations.each do |location|
  #     countries << location['country']
  #   end
  
  #   countries.uniq.each do |country|
  #     collection << { nct_id: nct_id, name: country, removed: false }
  #   end
  
  #   removed_countries.uniq.each do |country|
  #     collection << { nct_id: nct_id, name: country, removed: true }
  #   end
  
  #   collection
  # end

  add_mapping do
    [
      {
        table: :countries,
        root: [:protocolSection, :contactsLocationsModule, :locations, :country],
        columns: [
          { name: :name, value: :country },
          { name: :removed, value: false }
        ]
      },
      {
        table: :countries,
        root: [:derivedSection, :miscInfoModule, :removedCountries],
        columns: [
          { name: :name, value: :country },
          { name: :removed, value: true }
        ]
      }
    ]
  end  

end