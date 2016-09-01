require 'action_view'
include ActionView::Helpers::NumberHelper
module ClinicalTrials
  class FileManager

    def self.snapshot_files
      files_in("snapshots")
    end

    def self.csv_pipe_files
      files_in("csv_pipe_exports")
    end

    def self.files_in(dir)
      entries=[]
      server=ENV['FILESERVER_ENDPOINT']
      it=RestClient.get(server)
      doc=Nokogiri::XML(it)
      contents=doc.search('Contents')
      contents.each{|c|
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
      entries
    end
  end
end
