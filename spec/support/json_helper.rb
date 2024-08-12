module JsonHelper
  # folder is optional for possible future organization of json files
  def load_json(model_class, folder = "")

    file_name = model_class.name.underscore
    puts "Loading JSON file: #{file_name}.json"
    file_path = Rails.root.join("spec", "fixtures", "json", folder, "#{file_name}.json")

    # exit early if the file doesn't exist
    raise "File not found: #{file_path}" unless File.exist?(file_path)

    begin
      file_content = File.read(file_path)
      JSON.parse(file_content)
    rescue Errno::ENOENT => e
      raise "Error reading file: #{file_path} - #{e.message}"
    rescue JSON::ParserError => e
      raise "JSON parsing error in file: #{file_path} - #{e.message}"
    end
  end


  def load_study_json(nct_id)
    file_name = nct_id
    puts "Loading JSON file: #{file_name}.json"
    file_path = Rails.root.join("spec", "fixtures", "study", "#{file_name}.json")

    raise "File not found: #{file_path}" unless File.exist?(file_path)

    begin
      file_content = File.read(file_path)
      json_data = JSON.parse(file_content)
      json_data["studies"].first
    rescue Errno::ENOENT => e
      raise "Error reading file: #{file_path} - #{e.message}"
    rescue JSON::ParserError => e
      raise "JSON parsing error in file: #{file_path} - #{e.message}"
    end
  end


  def load_expected_data_for(nct_id, model)
    file_name = nct_id
    puts "Loading JSON file: #{file_name}.json"
    file_path = Rails.root.join("spec", "fixtures", "expected", "#{file_name}.json")

    raise "File not found: #{file_path}" unless File.exist?(file_path)

    begin
      file_content = File.read(file_path)
      json_data = JSON.parse(file_content)
      json_data["models"][model.name]
    rescue Errno::ENOENT => e
      raise "Error reading file: #{file_path} - #{e.message}"
    rescue JSON::ParserError => e
      raise "JSON parsing error in file: #{file_path} - #{e.message}"
    end
  end
end
