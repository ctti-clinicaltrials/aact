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

    def run(delimiter: '|')
      File.delete(@zipfile_name) if File.exist?(@zipfile_name)
      begin
        tempfiles = create_tempfiles(delimiter)
        if delimiter == ','
          system("zip -j -q #{@zipfile_name} #{@temp_dir}/*.csv")
        else
          system("zip -j -q #{@zipfile_name} #{@temp_dir}/*.txt")
        end

        FileRecord.post('pipefiles', @zipfile_name)
        File.delete(@zipfile_name) if File.exist?(@zipfile_name)
      ensure
        cleanup_tempfiles!
      end
    end

    private

    def create_tempfiles(delimiter)
      if !@table_names.empty?
        tables=@table_names
      else
        tables = StudyRelationship.loadable_tables
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
  end
end
