class TableExporter
  attr_reader :zipfile_name

  def initialize
    @temp_dir     = "#{Rails.root}/tmp"
    @zipfile_name = "#{@temp_dir}/export.zip"
    @connection   = ActiveRecord::Base.connection
  end

  def run(delimiter: ',')
    File.delete(@zipfile_name) if File.exist?(@zipfile_name)

    tempfiles = create_tempfiles(delimiter)

    Zip::File.open(@zipfile_name, Zip::File::CREATE) do |zipfile|
      tempfiles.each do |file|
        zipfile.add(File.basename(file), file.path)
      end
    end

    # TODO send to s3

    cleanup_files!
  end

  private

  def create_tempfiles(delimiter)
    create_temp_dir_if_none_exists!

    blacklist = %w(
      schema_migrations
      load_events
      study_xml_records
    )

    table_names = ActiveRecord::Base.connection.tables.reject do |table|
      blacklist.include?(table)
    end

    tempfiles = table_names.map { |table_name| "#{table_name}.csv" }
                           .map do |file_name|
                             path = "#{@temp_dir}/#{file_name}"
                             File.open(path, 'w') do |file|
                               file.write(export_table_to_csv(file_name, path, delimiter))
                               file
                             end
                           end
  end

  def export_table_to_csv(file_name, path, delimiter)
    table = File.basename(file_name, '.csv')
    @connection.execute("copy #{table} to '#{path}' with delimiter '#{delimiter}' csv header")
  end

  def cleanup_files!
    Dir.entries(@temp_dir).each do |file|
      file_with_path = "#{@temp_dir}/#{file}"
      File.delete(file_with_path) if File.extname(file) == '.csv'
    end
  end

  def create_temp_dir_if_none_exists!
    unless Dir.exist?(@temp_dir)
      Dir.mkdir(@temp_dir)
    end
  end
end
