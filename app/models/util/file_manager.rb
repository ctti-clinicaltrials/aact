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
      "/static"
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

    def self.monthly_snapshot_files
      results =  files_in('static_db_copies','monthly')
      results
    end

    def self.daily_snapshot_files
      results = files_in('static_db_copies','daily')
      results
    end

    def self.monthly_flat_files
      results = files_in('exported_files','monthly')
      results
    end

    def self.daily_flat_files
      results = files_in('exported_files','daily')
      results
    end

    #  ----  get files via linux op sys ------------------

    def backend_admin_schema_diagram
      "#{Rails.public_path}/static/documentation/aact_admin_schema.png"
    end

    def backend_schema_diagram
      "#{Rails.public_path}/static/documentation/aact_schema.png"
    end

    def backend_data_dictionary
      "#{Rails.public_path}/static/documentation/aact_data_definitions.xlsx"
    end

    def backend_table_dictionary
      "#{Rails.public_path}/static/documentation/aact_tables.xlsx"
    end

    def self.default_mesh_terms
      "#{Rails.public_path}/mesh/mesh_terms.txt"
    end

    def self.default_mesh_headings
      "#{Rails.public_path}/mesh/mesh_headings.txt"
    end

    def self.default_data_definitions
      Roo::Spreadsheet.open("#{Rails.public_path}/documentation/aact_data_definitions.xlsx")
    end

    #  ----  get files via url ------------------

    def self.admin_schema_diagram
      "/static/documentation/aact_admin_schema.png"
    end

    def self.schema_diagram
      "/static/documentation/aact_schema.png"
    end

    def self.data_dictionary
      "/static/documentation/aact_data_definitions.xlsx"
    end

    def self.table_dictionary
      "/static/documentation/aact_tables.xlsx"
    end

    #  ----  other utility methods  -------------

    def self.files_in(sub_dir, type)
      # type can be 'monthly' or 'daily'.  If 'daily', we provide only files date stamped this month.  All others go into monthly
      daily_entries=[]
      monthly_entries=[]
      dir="#{static_root_dir}/#{sub_dir}"
      file_names=Dir.entries(dir) - ['.','..']
      file_names.each {|file_name|
        file_location="#{dir}/#{file_name}"
        file_url="#{url_base}/#{sub_dir}/#{file_name}"
        size=File.open(file_location).size
        date_string=file_name.split('_').first
        # don't fail if unexpected file encountered
        begin
          date_created=(date_string.size==8 ? Date.parse(date_string).strftime("%m/%d/%Y") : nil)
          if created_in_current_month?(date_created)
            daily_entries << {:name=>file_name,:date_created=>date_created,:size=>number_to_human_size(size), :url=>file_url}
          else
            monthly_entries << {:name=>file_name,:date_created=>date_created,:size=>number_to_human_size(size), :url=>file_url}
          end
        rescue => e
          puts  "============= FileManager Error!! Problem in files_in #{sub_dir}  #{type} ======================="
          puts e
          puts "==================================================================================="
        end
      }
      return daily_entries.sort_by {|entry| entry[:name]}.reverse! if type == 'daily'
      return monthly_entries.sort_by {|entry| entry[:name]}.reverse! if type == 'monthly'
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

    def self.created_in_current_month?(str)
      current_month=Date.today.strftime("%m")
      current_year=Date.today.year.to_s
      month=str.split('/')[0]
      year=str.split('/').last
      return month == current_month && year == current_year
    end

    def created_first_day_of_month?(str)
      day=str[:date_created].split('/')[1]
      return day == '01'
    end

    def remove_snapshots
      remove_files(Util::FileManager.snapshot_files)
    end

    def remove_flat_files
      remove_files(Util::FileManager.flat_files)
    end

    def remove_files(files)
      # doesn't remove files created on the first day of the month
      files.each{|file|
        File.delete(file[:url]) if File.exist?(file[:url]) && !created_first_day_of_month?(file)
      }
    end

  end
end
