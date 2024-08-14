module JsonHelper
  
  def load_json_for(model, folder: "import")
    file_name = "#{model.name.underscore}.json"
    file_path = Rails.root.join("spec", "fixtures", "json", "models", folder, file_name)
    raise "File not found: #{file_path}" unless File.exist?(file_path)
    parse_json_from(file_path)
  end

  # to support json structure: { "Model 1": [], "Model 2": []} - simplify if not needed
  def load_expected_data_for(model)
    json = load_json_for(model, folder: "output")
    # json[model.name]
  end


  private

  def filename(subject)
    subject.is_a?(Class) ? subject.name.underscore : subject
  end

  # TODO: Better name?
  def base_folder(subject)
    subject.is_a?(Class) ? "models" : "studies"
  end

  def parse_json_from(file_path)
    content = File.read(file_path)
    JSON.parse(content)
    rescue Errno::ENOENT => e
      raise "Error reading file: #{file_path} - #{e.message}"
    rescue JSON::ParserError => e
      raise "JSON parsing error in file: #{file_path} - #{e.message}"
  end
end