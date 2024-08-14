module JsonHelper
  
  def load_json(filename, path)
    file = resolve_file_name(filename)
    file_path = path.join(file)
    parse_json_from(file_path)
  end

  private

  def parse_json_from(file_path)
    raise "File not found: #{file_path}" unless File.exist?(file_path)
    content = File.read(file_path)
    JSON.parse(content)
    rescue Errno::ENOENT => e
      raise "Error reading file: #{file_path} - #{e.message}"
    rescue JSON::ParserError => e
      raise "JSON parsing error in file: #{file_path} - #{e.message}"
  end

  def resolve_file_name(subject)
    subject.is_a?(Class) ? "#{subject.name.underscore}.json" : subject
  end

  def spec_root
    @spec_root ||= Rails.root.join("spec")
  end

  def models
    @models ||= spec_root.join("fixtures", "models")
  end

  def models_import_path
    @models_import_path ||= models.join("import")
  end

  def models_expected_path
    @models_expected_path ||= models.join("expected")
  end

  def models_support_path
    @support ||= spec_root.join("support", "json_data")
  end
end