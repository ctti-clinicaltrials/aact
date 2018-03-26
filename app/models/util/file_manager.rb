require 'action_view'
require 'open-uri'
include ActionView::Helpers::NumberHelper
module Util
  class FileManager

    def static_copies_directory
      "#{Rails.public_path}/static/static_db_copies"
    end

    def flat_files_directory
      "#{Rails.public_path}/static/exported_files"
    end

    def pg_dump_file
      "#{Rails.public_path}/static/tmp/postgres.dmp"
    end

    def dump_directory
      "#{Rails.public_path}/static/tmp"
    end

    def admin_schema_diagram
      "#{Rails.public_path}/static/documentation/aact_admin_schema.png"
    end

    def schema_diagram
      "#{Rails.public_path}/static/documentation/aact_schema.png"
    end

    def data_dictionary
      "#{Rails.public_path}/static/documentation/aact_data_definitions.xlsx"
    end

    def table_dictionary
      "#{Rails.public_path}/static/documentation/aact_tables.xlsx"
    end

    def default_mesh_terms
      "#{Rails.public_path}/mesh/mesh_terms.txt"
    end

    def default_mesh_headings
      "#{Rails.public_path}/mesh/mesh_headings.txt"
    end

    def default_data_definitions
      Roo::Spreadsheet.open("#{Rails.public_path}/documentation/aact_data_definitions.xlsx")
    end

    def self.files_in(dir, type)
      new.files_in(dir, type)
    end

    def files_in(sub_dir, type)
      # type ('monthly' or 'daily') identify the subdirectory to use to get the files.
      entries=[]
      dir="/aact-files/#{sub_dir}/#{type}"
      file_names=Dir.entries(dir) - ['.','..']
      file_names.each {|file_name|
        begin
          file_url="#{dir}/#{file_name}"
          size=File.open(file_url).size
          date_string=file_name.split('_').first
          date_created=(date_string.size==8 ? Date.parse(date_string).strftime("%m/%d/%Y") : nil)
          entries << {:name=>file_name,:date_created=>date_created,:size=>number_to_human_size(size), :url=>file_url}
        rescue => e
          # just skip if unexpected file encountered
          puts e
        end
      }
      entries.sort_by {|entry| entry[:name]}.reverse!
    end

    def self.db_log_file_content(params)
      return [] if params.nil? or params[:day].nil?
      day=params[:day].capitalize
      file_name="/static/logs/postgresql-#{day}.log"
      if File.exist?(file_name)
        File.open(file_name)
      else
        []
      end
    end

    def make_file_from_website(fname,url)
      return_file="/static/tmp/#{fname}"
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

    def save_static_copy
      fpm=Util::FilePresentationManager.new
      schema_diagram_file=File.open("#{schema_diagram}")
      admin_schema_diagram_file=File.open("#{admin_schema_diagram}")
      data_dictionary_file=File.open("#{data_dictionary}")
      nlm_protocol_file=make_file_from_website("nlm_protocol_definitions.html",fpm.nlm_protocol_data_url)
      nlm_results_file=make_file_from_website("nlm_results_definitions.html",fpm.nlm_results_data_url)

      date_stamp=Time.now.strftime('%Y%m%d')
      if created_first_day_of_month? date_stamp
        zip_file_name="#{static_copies_directory}/monthly/#{date_stamp}_clinical_trials.zip"
      else
        zip_file_name="#{static_copies_directory}/daily/#{date_stamp}_clinical_trials.zip"
      end
      File.delete(zip_file_name) if File.exist?(zip_file_name)
      Zip::File.open(zip_file_name, Zip::File::CREATE) {|zipfile|
        zipfile.add('schema_diagram.png',schema_diagram_file)
        zipfile.add('admin_schema_diagram.png',admin_schema_diagram_file)
        zipfile.add('data_dictionary.xlsx',data_dictionary_file)
        zipfile.add('postgres_data.dmp',pg_dump_file)
        zipfile.add('nlm_protocol_definitions.html',nlm_protocol_file)
        zipfile.add('nlm_results_definitions.html',nlm_results_file)
      }
      return zip_file_name
    end

    def remove_daily_snapshots
      FileUtils.rm_rf(Dir['/aact-files/static_db_copies/daily/*.zip'])
    end

    def remove_daily_flat_files
      FileUtils.rm_rf(Dir['/aact-files/exported_files/daily/*.zip'])
    end

  end
end
