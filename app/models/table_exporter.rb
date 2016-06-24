class TableExporter
  attr_reader :zipfile_name

  def initialize(tables: get_table_names(all: true))
    @temp_dir     = "#{Rails.root}/tmp"
    @zipfile_name = "#{@temp_dir}/export.zip"
    @connection   = ActiveRecord::Base.connection
    @tables       = tables
  end

  def run(delimiter: ',', should_upload_to_s3: false)
    File.delete(@zipfile_name) if File.exist?(@zipfile_name)

    tempfiles = create_tempfiles(delimiter)

    Zip::File.open(@zipfile_name, Zip::File::CREATE) do |zipfile|
      tempfiles.each do |file|
        zipfile.add(File.basename(file), file.path)
      end
    end

    if should_upload_to_s3
      upload_to_s3
    end

    cleanup_files!
  end

  private

  def get_table_names(all: false, tables: nil)
    all_tables = ActiveRecord::Base.connection.tables

    blacklist = %w(
      schema_migrations
      load_events
      study_xml_records
    )

    if !all
      blacklist.concat(all_tables - tables)
    end

    all_tables.reject do |table|
      blacklist.include?(table)
    end
  end

  def create_tempfiles(delimiter)
    create_temp_dir_if_none_exists!

    table_names = get_table_names(tables: @tables)

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

  def upload_to_s3
    s3_file_name = "csv-export-#{Date.today}"

    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    obj = s3.bucket(ENV['S3_BUCKET_NAME']).object(s3_file_name)
    obj.upload_file(@zipfile_name)
  end
end
