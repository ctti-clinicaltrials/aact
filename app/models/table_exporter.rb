class TableExporter
  ZIPFILE_NAME = "#{Rails.root}/tmp/export.zip"
  CONNECTION   = ActiveRecord::Base.connection

  def run
    File.delete(ZIPFILE_NAME) if File.exist?(ZIPFILE_NAME)

    tempfiles = create_tempfiles

    Zip::File.open(ZIPFILE_NAME, Zip::File::CREATE) do |zipfile|
      tempfiles.each do |file|
        zipfile.add(File.basename(file), file.path)
      end
    end
  end

  private

  def create_tempfiles
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
                             path = "#{Rails.root}/tmp/#{file_name}"
                             File.open(path, 'w') do |file|
                               file.write(export_table_to_csv(file_name, path))
                               file
                             end
                           end
  end

  def export_table_to_csv(file_name, path, delimiter: ',')
    table = File.basename(file_name, '.csv')
    CONNECTION.execute("copy #{table} to '#{path}' with delimiter '#{delimiter}' csv header")
  end
end
