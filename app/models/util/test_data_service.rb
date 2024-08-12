module Util
  module TestDataService

    # TODO: ability to extract data for different schemas

    def self.extract_data_for(nct_id)
      data = { nct_id: nct_id, models: {} }
      tables_to_extract.each do |table|
        model_class = table.classify.constantize
        records = model_class.where(nct_id: nct_id).map { |r| r.attributes.except('id') }
        data[:models][model_class.name] = records


      end
      save_to_file(nct_id, data)
    end

    def self.tables_to_extract
      StudyRelationship.loadable_tables
    end

    private

    def self.save_to_file(nct_id, data)
      file_path = Rails.root.join("tmp", "expected_data_#{nct_id}.json")
      File.open(file_path, "w") do |file|
        file.write(JSON.pretty_generate(data))
      end
      puts "Expected data saved to #{file_path}" 
    end
  end
end
