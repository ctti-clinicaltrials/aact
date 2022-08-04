require 'action_view'
require 'open-uri'
require 'fileutils'
include ActionView::Helpers::NumberHelper
module Util
  class FileManager

    attr_accessor :root_dir

    def initialize
      @root_dir = "#{Rails.public_path}/static"
      FileUtils.mkdir_p root_dir
      FileUtils.mkdir_p "#{root_dir}/static_db_copies/daily"
      FileUtils.mkdir_p "#{root_dir}/static_db_copies/monthly"
      FileUtils.mkdir_p "#{root_dir}/exported_files/daily"
      FileUtils.mkdir_p "#{root_dir}/exported_files/monthly"
      FileUtils.mkdir_p "#{root_dir}/db_backups"
      FileUtils.mkdir_p "#{root_dir}/documentation"
      FileUtils.mkdir_p "#{root_dir}/logs"
      FileUtils.mkdir_p "#{root_dir}/tmp"
      FileUtils.mkdir_p "#{root_dir}/other"
      FileUtils.mkdir_p "#{root_dir}/xml_downloads"
      FileUtils.mkdir_p "#{root_dir}/exported_files/covid-19"
      FileUtils.mkdir_p "#{root_dir}/differences/single-row"
      FileUtils.mkdir_p "#{root_dir}/differences/study_statistics"
       #archive folders
       FileUtils.mkdir_p "#{root_dir}/ctgov_archive_static_db_copies/daily"
       FileUtils.mkdir_p "#{root_dir}/ctgov_archive_static_db_copies/monthly"
       FileUtils.mkdir_p "#{root_dir}/ctgov_archive_exported_files/daily"
       FileUtils.mkdir_p "#{root_dir}/ctgov_archive_exported_files/monthly"
    end

    def nlm_protocol_data_url
      "https://prsinfo.clinicaltrials.gov/definitions.html"
    end

    def nlm_results_data_url
      "https://prsinfo.clinicaltrials.gov/results_definitions.html"
    end

    def base_folder(schema = 'ctgov')
      return"#{root_dir}/ctgov_archive_" if schema =~ /archive/
        
      return "#{root_dir}/"
    end

    def static_copies_directory(schema = 'ctgov')
      folder = "#{base_folder(schema)}static_db_copies" 
      if created_first_day_of_month? Time.zone.now.strftime('%Y%m%d')
        "#{folder}/monthly"
      else
        "#{folder}/daily"
      end
    end

    def flat_files_directory(schema='')
      folder = "#{base_folder(schema)}exported_files" 
      if created_first_day_of_month? Time.zone.now.strftime('%Y%m%d')
        "#{folder}/monthly"
      else
        "#{folder}/daily"
      end
    end

    def pg_dump_file
      "#{root_dir}/tmp/postgres.dmp"
    end

    def dump_directory
      "#{root_dir}/tmp"
    end

    def covid_file_directory
      "#{root_dir}/exported_files/covid-19"
    end

    def differences_directory
      "#{root_dir}/differences/single-row"
    end

    def schema_diagram
      "#{root_dir}/documentation/aact_schema.png"
    end

    def data_dictionary
      "#{root_dir}/documentation/aact_data_definitions.xlsx"
    end

    def table_dictionary
      "#{root_dir}/documentation/aact_tables.xlsx"
    end

    def default_mesh_terms
      "#{Rails.public_path}/mesh/mesh_terms.txt"
    end

    def default_mesh_headings
      "#{Rails.public_path}/mesh/mesh_headings.txt"
    end

    def study_statistics_directory
      "#{root_dir}/differences/study_statistics"
    end

    def default_data_definitions
      begin
        Roo::Spreadsheet.open("#{root_dir}/documentation/aact_data_definitions.xlsx")
      rescue
        # No guarantee the file exists
      end
    end

    def make_file_from_website(fname, url)
      return_file="#{root_dir}/tmp/#{fname}"
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

    def created_first_day_of_month?(str)
      day=str.split('/')[1]
      return day == '01'
    end

    # package files for archival purposes
    def save_static_copy
      # collect files to include the zip
      files_to_zip = {}
      nlm_protocol_file         = make_file_from_website("nlm_protocol_definitions.html", nlm_protocol_data_url)
      nlm_results_file          = make_file_from_website("nlm_results_definitions.html", nlm_results_data_url)
      files_to_zip['schema_diagram.png']            = File.open(schema_diagram)       if File.exists?(schema_diagram)
      files_to_zip['data_dictionary.xlsx']          = File.open(data_dictionary)      if File.exists?(data_dictionary)
      files_to_zip['postgres_data.dmp']             = File.open(pg_dump_file)         if File.exists?(pg_dump_file)
      files_to_zip['nlm_protocol_definitions.html'] = nlm_protocol_file               if nlm_protocol_file
      files_to_zip['nlm_results_definitions.html']  = nlm_results_file                if nlm_results_file
      
      # generate the filename
      date_stamp = Time.zone.now.strftime('%Y%m%d')
      zip_file_name="#{static_copies_directory}/#{date_stamp}_clinical_trials.zip"
     
      # zip files
      File.delete(zip_file_name) if File.exist?(zip_file_name)
      Zip::File.open(zip_file_name, Zip::File::CREATE) do |zipfile|
        files_to_zip.each do |entry|
          zipfile.add(entry.first, entry.last)
        end
      end

      # upload file to the cloud
      filename = File.basename(zip_file_name)
      record = FileRecord.create(file_type: "snapshot", filename: "#{filename}", file_size: File.size(zip_file_name)) 
      record.file.attach(io: File.open(zip_file_name), filename: "#{filename}")
      record.update(url: record.file.service.send(:object_for, record.file.key).public_url)
      zip_file_name
    end
  end
end
