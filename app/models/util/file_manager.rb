require 'action_view'
require 'open-uri'
include ActionView::Helpers::NumberHelper
module Util
  class FileManager

    def static_copies_directory
      "/static/static_db_copies"
    end

    def flat_files_directory
      "/static/exported_files"
    end

    def pg_dump_file
      "/static/tmp/postgres.dmp"
    end

    def dump_directory
      "/static/tmp"
    end

    #  ----  get files via linux op sys ------------------

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

    def self.default_mesh_terms
      "#{Rails.public_path}/mesh/mesh_terms.txt"
    end

    def self.default_mesh_headings
      "#{Rails.public_path}/mesh/mesh_headings.txt"
    end

    def self.default_data_definitions
      Roo::Spreadsheet.open("#{Rails.public_path}/documentation/aact_data_definitions.xlsx")
    end

    def self.files_in(dir, type)
      new.files_in(dir, type)
    end

    def files_in(sub_dir, type)
      # type ('monthly' or 'daily') identify the subdirectory to use to get the files.
      entries=[]
      dir="/static/#{sub_dir}/#{type}"
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

    def all_files_in(dir)
      files=[]
      file_names=Dir.entries(dir) - ['.','..']
      file_names.each {|file_name|
        file_location="#{dir}/#{file_name}"
        file_url="#{dir}/#{file_name}"
        size=File.open(file_location).size
        date_string=file_name.split('_').first
        date_created=(date_string.size==8 ? Date.parse(date_string).strftime("%m/%d/%Y") : nil)
        files << {:name=>file_name,:date_created=>date_created,:size=>number_to_human_size(size), :url=>file_url}
      }
      return files.sort_by {|entry| entry[:name]}.reverse!
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

    def remove_daily_snapshots
      files_in(Util::FileManager.static_copies_directory).each{ |file| File.delete(file[:url]) }
    end

    def remove_daily_flat_files
      files_in(Util::FileManager.flat_files_directory).each{ |file| File.delete(file[:url]) }
    end

  end
end
