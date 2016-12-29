require 'action_view'
include ActionView::Helpers::NumberHelper
module ClinicalTrials
  class FileManager

    def self.data_dump_directory
      '/app/tmp'
    end

    def self.nlm_protocol_data_url
      "https://prsinfo.clinicaltrials.gov/definitions.html"
    end

    def self.nlm_results_data_url
      "https://prsinfo.clinicaltrials.gov/results_definitions.html"
    end

    def self.server
      ENV['FILESERVER_ENDPOINT']
    end

    def self.snapshot_files
      files_in("snapshots")
    end

    def self.pipe_delimited_files
      files_in("csv_pipe_exports")
    end

    def self.analyst_guide
      "#{server}/documentation/analyst_guide.png"
    end

    def self.schema_diagram
      "#{server}/documentation/aact_schema.png"
    end

    def self.data_dictionary
      "#{server}/documentation/aact_data_definitions.xlsx"
    end

    def self.get_file(params)
      file_name=params[:file_name]
      directory_name=params[:directory_name] ||= 'xml_downloads'
      File.open("#{file_name}", 'wb') { |out_file|
        s3 = Aws::S3::Client.new(region: ENV['AWS_REGION'])
        s3.get_object({ bucket: ENV['S3_BUCKET_NAME'], key: "#{directory_name}/#{file_name}"}, target: out_file)
      }
      Zip::File.open(file_name)
    end

    def self.files_in(dir)
      entries=[]
      server=ENV['FILESERVER_ENDPOINT']
      it=RestClient.get(server)
      doc=Nokogiri::XML(it)
      contents=doc.search('Contents')
      contents.each {|c|
        full_name=c.children.select{|c|c.name=='Key'}.first.children.text
        last_modified=(c.children.select{|c|c.name=='LastModified'}.first.children.text).to_date.strftime('%Y-%m-%d')
        size=c.children.select{|c|c.name=='Size'}.first.children.text

        dir_and_file=full_name.split('/')
        if dir_and_file.first == dir
          file_name=dir_and_file.last
          file_url="#{server}/#{full_name}"
          entries << {:name=>dir_and_file.last,:last_modified=>last_modified,:size=>number_to_human_size(size), :url=>file_url}
        end
      }
      entries.sort_by {|entry| entry[:name]}.reverse!
    end

    def dump_database
      dump_file_name='/app/tmp/postgres.dmp'
      File.delete(dump_file_name) if File.exist?(dump_file_name)
      `PGPASSWORD=$RDS_DB_SUPER_PASSWORD pg_dump -h aact-dev.cr4nrslb1lw7.us-east-1.rds.amazonaws.com -p 5432 -U dbadmin --no-password --clean --exclude-table study_xml_records --exclude-table schema_migrations --exclude-table load_events --exclude-table statistics --exclude-table sanity_checks --exclude-table use_cases --exclude-table use_case_attachments -c -C -Fc -f /app/tmp/postgres.dmp aact`
      return dump_file_name
    end

    def get_reg_file(params)
      file_name=params[:file_name]
      out_file_name="/app/tmp/#{file_name}"
      directory_name=params[:directory_name] ||= 'xml_downloads'
      File.open(out_file_name, 'wb') { |out_file|
        s3 = Aws::S3::Client.new(region: ENV['AWS_REGION'])
        s3.get_object({ bucket: ENV['S3_BUCKET_NAME'], key: "#{directory_name}/#{file_name}"}, target: out_file)
      }
      File.open(out_file_name)
    end

    def take_snapshot
      dump_database
      postgres_dump_file=File.open('/app/tmp/postgres.dmp')
      schema_diagram_file=get_reg_file({:directory_name=>'documentation',:file_name=>'aact_schema.png'})
      data_dictionary_file=get_reg_file({:directory_name=>'documentation',:file_name=>'aact_data_definitions.xlsx'})

      zip_file_name="#{Time.now.strftime('%Y%m%d')}_clinical_trials.zip"
      File.delete(zip_file_name) if File.exist?(zip_file_name)
      Zip::File.open(zip_file_name, Zip::File::CREATE) {|zipfile|
        zipfile.add('data_dictionary.xlsx',data_dictionary_file)
        zipfile.add('schema_diagram.png',schema_diagram_file)
        zipfile.add('postgres_data.dmp',postgres_dump_file)
      }
      upload_to_s3({:directory_name=>'snapshots',:file_name=>zip_file_name})
    end

    def upload_to_s3(params={})
      directory_name=params[:directory_name]
      file_name=params[:file_name]
      file=File.open(file_name)
      s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
      s3_destination="#{directory_name}/#{file_name}"
      obj = s3.bucket(ENV['S3_BUCKET_NAME']).object(s3_destination)
      obj.upload_file(file)
    end
  end
end
