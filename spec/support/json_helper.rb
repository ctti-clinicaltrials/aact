module JsonHelper
  # folder is optional for possible future organization of json files
  def load_json(model_class, folder = "")

    file_name = model_class.name.underscore
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
end
