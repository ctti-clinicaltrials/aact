module Util
  class TableExporter
    attr_reader :zipfile_name, :table_names

    def initialize(tables=[],schema='')
      @schema = schema
      @temp_dir     = "#{Util::FileManager.new.dump_directory}/export"
      @zipfile_name = "#{@temp_dir}/#{Time.zone.now.strftime('%Y%m%d')}_export.zip"
      @table_names  = tables
      create_temp_dir_if_none_exists!
    end

    def run(delimiter: '|', should_archive: true)
      load_event = Support::LoadEvent.create({:event_type=>'table_export',:status=>'running',:description=>'',:problems=>''})
      File.delete(@zipfile_name) if File.exist?(@zipfile_name)
      begin
        tempfiles = create_tempfiles(delimiter)
        if delimiter == ','
          system("zip -j -q #{@zipfile_name} #{@temp_dir}/*.csv")
        else
          system("zip -j -q #{@zipfile_name} #{@temp_dir}/*.txt")
        end
        filename = File.basename(@zipfile_name).gsub("export","pipe-delimited-export")
        record = FileRecord.create(file_type: "pipefiles", filename: filename, file_size: File.size(@zipfile_name))
        record.file.attach(io: File.open(@zipfile_name), filename: filename)
        record.update(url: record.file.service.send(:object_for, record.file.key).public_url)

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
        tables=Util::DbManager.loadable_tables
      end
      tempfiles = tables.map { |table_name| delimiter == ',' ? "#{table_name}.csv" : "#{table_name}.txt" }
                             .map do |file_name|
                               path = "#{@temp_dir}/#{file_name}"
                               File.open(path, 'wb+') do |file|
                                 export_table_to_csv(file, file_name, path, delimiter)
                                 file
                               end
                             end
    end

    def export_table_to_csv(file, file_name, path, delimiter)
      table = File.basename(file_name, delimiter == ',' ? '.csv' : '.txt')
      connection  = ActiveRecord::Base.connection.raw_connection
      connection.copy_data("copy #{table} to STDOUT with delimiter '#{delimiter}' csv header") do
        while row = connection.get_copy_data
          # convert all \n to ~.  Then when you write to the file, convert last ~ back to \n
          # to prevent it from concatenating all rows into one big long string
          fixed_row=row.gsub(/\"\"/, '').gsub(/\n\s/, '~').gsub(/\n/, '~')
          file.write(fixed_row.gsub(/\~$/,"\n"))
        end
      end
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

      folder =  Util::FileManager.new.flat_files_directory(@schema)
      archive_file_name="#{folder}/#{Time.zone.now.strftime('%Y%m%d')}_#{file_type}.zip"
      FileUtils.mv(@zipfile_name, archive_file_name)
    end
  end
end
