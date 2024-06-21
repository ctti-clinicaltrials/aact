module Util
  class TableExporter
    attr_reader :zipfile_name, :table_names

    def initialize(tables=[],schema='ctgov')
      @schema = schema
      @temp_dir     = "#{Util::FileManager.new.dump_directory}/export"
      @zipfile_name = "#{@temp_dir}/#{Time.zone.now.strftime('%Y%m%d')}_export_#{schema}.zip"
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
        
        # no need to set search path here but still will use with_connection
        ActiveRecord::Base.connection_pool.with_connection do |conn|
          # conn.execute("SET search_path TO #{@schema}, support, public")
          FileRecord.post('pipefiles', @zipfile_name)
        end
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
      # to make sure each export runs in its own connection
      ActiveRecord::Base.connection_pool.with_connection do |conn|
        # connection  = ActiveRecord::Base.connection.raw_connection
        connection = conn.raw_connection
        schema_table = "#{@schema}.#{table}"
        connection.copy_data("copy #{schema_table} to STDOUT with delimiter '#{delimiter}' csv header") do
          while row = connection.get_copy_data
            # convert all \n to ~.  Then when you write to the file, convert last ~ back to \n
            # to prevent it from concatenating all rows into one big long string
            fixed_row=row.gsub(/\"\"/, '').gsub(/\n\s/, '~').gsub(/\n/, '~')
            file.write(fixed_row.gsub(/\~$/,"\n"))
          end
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
