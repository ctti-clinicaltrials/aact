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

    # This method exports all the tables as delimited files
    def create_tempfiles(delimiter)
      tables = @table_names.empty? ? StudyRelationship.loadable_tables : @table_names

      tables.map do |table_name| 
        file_name = delimiter == ',' ? "#{table_name}.csv" : "#{table_name}.txt"
        path = "#{@temp_dir}/#{file_name}"
        File.open(path, 'wb+') do |file|
          export_table(table_name, file, delimiter)
        end
      end
    end

    # exports table to csv file using delimter
    def export_table(table, file, delimiter)
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
