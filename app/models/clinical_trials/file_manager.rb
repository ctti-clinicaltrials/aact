require 'action_view'
include ActionView::Helpers::NumberHelper
module ClinicalTrials
  class FileManager

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
      return Zip::File.open(file_name) if File.exist?(file_name)
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
      entries.sort_by {|entry| entry[:last_modified]}.reverse!
    end

    def upload_to_s3(params={})
      directory_name=params[:directory_name]
      file_name=params[:file_name]
      file=params[:file]
      s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
      obj = s3.bucket(ENV['S3_BUCKET_NAME']).object("#{directory_name}/#{file_name}")
      obj.upload_file(file)
    end
  end
end
