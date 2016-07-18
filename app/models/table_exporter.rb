class TableExporter
  attr_reader :zipfile_name

  def initialize(tables: get_table_names(all: true))
    @temp_dir     = "#{Rails.root}/tmp"
    @zipfile_name = "#{@temp_dir}/export.zip"
    @connection   = ActiveRecord::Base.connection.raw_connection
    @tables       = tables
  end

  def run(delimiter: ',', should_upload_to_s3: false)
    load_event = ClinicalTrials::LoadEvent.create(event_type: 'table_export')

    File.delete(@zipfile_name) if File.exist?(@zipfile_name)

    begin
      tempfiles = create_tempfiles(delimiter)

      if delimiter == ','
        system("zip -j -q #{Rails.root}/tmp/export.zip #{@temp_dir}/*.csv")
      else
        system("zip -j -q #{Rails.root}/tmp/export.zip #{@temp_dir}/*.txt")
      end

      if should_upload_to_s3
        upload_to_s3(delimiter)
      end

    ensure
      cleanup_tempfiles!
    end

    load_event.complete
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

    tempfiles = table_names.map { |table_name| delimiter == ',' ? "#{table_name}.csv" : "#{table_name}.txt" }
                           .map do |file_name|
                             path = "#{@temp_dir}/#{file_name}"
                             File.open(path, 'wb+') do |file|
                               file.write(export_table_to_csv(file_name, path, delimiter))
                               file
                             end
                           end
  end

  def export_table_to_csv(file_name, path, delimiter)
    table = File.basename(file_name, delimiter == ',' ? '.csv' : '.txt')
    string = ''
    @connection.copy_data("copy #{table} to STDOUT with delimiter '#{delimiter}' csv header") do
      while row = @connection.get_copy_data
        string << row
      end
    end
    string.gsub(/\"\"/, '').gsub(/\n\s/, '')
  end

  def cleanup_tempfiles!
    Dir.entries(@temp_dir).each do |file|
      file_with_path = "#{@temp_dir}/#{file}"
      File.delete(file_with_path) if File.extname(file) == '.csv' || File.extname(file) == '.txt'
    end
  end

  def create_temp_dir_if_none_exists!
    unless Dir.exist?(@temp_dir)
      Dir.mkdir(@temp_dir)
    end
  end

  def upload_to_s3(delimiter)
    s3_file_name = if delimiter == ','
                     "csv-export"
                   elsif delimiter == '|'
                     "pipe-delimited-export"
                   end

    s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
    obj = s3.bucket(ENV['S3_BUCKET_NAME']).object("csv_pipe_exports/#{Date.today}-#{s3_file_name}")
    obj.upload_file(@zipfile_name)
  end
end
