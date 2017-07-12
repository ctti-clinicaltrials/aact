module ClinicalTrials
  class TableExporter
    attr_reader :zipfile_name, :table_names

    def initialize(tables=[])
      @temp_dir     = "#{ClinicalTrials::FileManager.dump_directory}/export"
      @zipfile_name = "#{@temp_dir}/#{Time.now.strftime('%Y%m%d')}_export.zip"
      @connection   = ActiveRecord::Base.connection.raw_connection
      @table_names  = tables
      create_temp_dir_if_none_exists!
    end

    def run(delimiter: '|', should_archive: true)
      load_event = LoadEvent.create({:event_type=>'table_export',:status=>'running',:description=>'',:problems=>''})
      File.delete(@zipfile_name) if File.exist?(@zipfile_name)

      begin
        tempfiles = create_tempfiles(delimiter)

        if delimiter == ','
          system("zip -j -q #{@zipfile_name} #{@temp_dir}/*.csv")
        else
          system("zip -j -q #{@zipfile_name} #{@temp_dir}/*.txt")
        end

        if should_archive
          archive(delimiter)
        end

      ensure
        cleanup_tempfiles!
      end
      load_event.complete
    end

    private

    def create_tempfiles(delimiter)
      if !@table_names.empty?
        tables=@table_names
      else
        tables=ClinicalTrials::Updater.loadable_tables
      end
      tempfiles = tables.map { |table_name| delimiter == ',' ? "#{table_name}.csv" : "#{table_name}.txt" }
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

    def archive(delimiter)
      file_type = if delimiter == ','
                       "csv-export"
                     elsif delimiter == '|'
                       "pipe-delimited-export"
                     end

      archive_file_name="#{ClinicalTrials::FileManager.flat_files_directory}/#{Time.now.strftime('%Y%m%d')}_#{file_type}.zip"
      FileUtils.mv(@zipfile_name, archive_file_name)
    end
  end
end
