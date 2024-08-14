module JsonHelper
  
  def load_json_for(model, folder: "import")
    file_path = Rails.root.join("spec", "fixtures", "models", folder, filename(model))
    raise "File not found: #{file_path}" unless File.exist?(file_path)
    parse_json_from(file_path)
  end

  def load_expected_data_for(model)
    json = load_json_for(model, folder: "output")
    # json[model.name]
  end


  private

  def filename(subject)
    subject.is_a?(Class) ? "#{subject.name.underscore}.json" : subject
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