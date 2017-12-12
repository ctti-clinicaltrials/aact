require 'action_view'
require 'open-uri'
include ActionView::Helpers::NumberHelper
module Util
  class FileManager

    def nlm_protocol_data_url
      "https://prsinfo.clinicaltrials.gov/definitions.html"
    end

    def nlm_results_data_url
      "https://prsinfo.clinicaltrials.gov/results_definitions.html"
    end

    def self.url_base
      '/static'
    end

    def self.static_root_dir
      '/aact-files'
    end

    def static_root_dir
      '/aact-files'
    end

    def self.dump_directory
      "#{static_root_dir}/tmp"
    end

    def dump_directory
      "#{static_root_dir}/tmp"
    end

    def self.xml_file_directory
      "#{static_root_dir}/xml_downloads"
    end

    def pg_dump_file
      "#{static_root_dir}/tmp/postgres.dmp"
    end

    def self.static_copies_directory
      "#{static_root_dir}/static_db_copies"
    end

    def self.flat_files_directory
      "#{static_root_dir}/exported_files"
    end

    def self.snapshot_files
      files_in("static_db_copies")
    end

    def self.pipe_delimited_files
      files_in("exported_files")
    end

    def self.documentation_directory
      "#{url_base}/documentation"
    end

    def self.admin_schema_diagram
      "#{self.documentation_directory}/aact_admin_schema.png"
    end

    def self.schema_diagram
      "#{self.documentation_directory}/aact_schema.png"
    end

    def self.data_dictionary
      "#{self.documentation_directory}/aact_data_definitions.xlsx"
    end

    def self.backend_data_dictionary
      "#{static_root_dir}/documentation/aact_data_definitions.xlsx"
    end

    def self.table_dictionary
      "#{self.documentation_directory}/aact_tables.xlsx"
    end

    def self.backend_table_dictionary
      "#{static_root_dir}/documentation/aact_tables.xlsx"
    end

    def self.default_data_definitions
      Roo::Spreadsheet.open("#{self.static_root_dir}/documentation/aact_data_definitions.xlsx")
    end

    def self.default_mesh_terms
      "#{Rails.public_path}/mesh/mesh_terms.txt"
    end

    def self.default_mesh_headings
      "#{Rails.public_path}/mesh/mesh_headings.txt"
    end

    def self.files_in(sub_dir)
      entries=[]
      dir="#{static_root_dir}/#{sub_dir}"
      file_names=Dir.entries(dir) - ['.','..']
      file_names.each {|file_name|
        file_location="#{dir}/#{file_name}"
        file_url="#{url_base}/#{sub_dir}/#{file_name}"
        size=File.open(file_location).size
        date_string=file_name.split('_').first
        date_created=(date_string.size==8 ? Date.parse(date_string).strftime("%m/%d/%Y") : date_string)
        entries << {:name=>file_name,:date_created=>date_created,:size=>number_to_human_size(size), :url=>file_url}
      }
      entries.sort_by {|entry| entry[:name]}.reverse!
    end

    def self.db_log_file_content(params)
      return [] if params.nil? or params[:day].nil?
      day=params[:day].capitalize
      file_name="#{static_root_dir}/logs/postgresql-#{day}.log"
      if File.exist?(file_name)
        File.open(file_name)
      else
        []
      end
    end

    def make_file_from_website(fname,url)
      return_file="#{static_root_dir}/tmp/#{fname}"
      File.delete(return_file) if File.exist?(return_file)
      open(url) {|site|
        open(return_file, "wb"){|out_file|
            d=site.read
            out_file.write(d)
        }
      }
      return File.open(return_file)
    end

    def get_dump_file_from(static_file)
      return static_file if `file --brief --mime-type "#{static_file}"` == "application/octet-stream\n"
      if `file --brief --mime-type "#{static_file}"` == "application/zip\n"
         Zip::File.open(static_file) { |zipfile|
           zipfile.each { |file|
             return file if file.name=='postgres_data.dmp'
           }
        }
      end
    end

  end
end
