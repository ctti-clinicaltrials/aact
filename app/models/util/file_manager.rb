# frozen_string_literal: true

module Util
  # manage files generated
  class FileManager
    def initialize
      FileUtils.mkdir_p root_dir
      FileUtils.mkdir_p "#{root_dir}/tmp"
      FileUtils.mkdir_p "#{root_dir}/static_db_copies/daily"
      FileUtils.mkdir_p "#{root_dir}/static_db_copies/monthly"
      FileUtils.mkdir_p "#{root_dir}/exported_files/daily"
      FileUtils.mkdir_p "#{root_dir}/exported_files/monthly"
      FileUtils.mkdir_p "#{root_dir}/db_backups"
      FileUtils.mkdir_p "#{root_dir}/documentation"
      FileUtils.mkdir_p "#{root_dir}/exported_files/covid-19"
    end

    def documentation_files
      {
        'https://prsinfo.clinicaltrials.gov/definitions.html' => 'nlm_protocol_definitions.html',
        'https://prsinfo.clinicaltrials.gov/results_definitions.html' => 'nlm_results_definitions.html',
        'https://aact.ctti-clinicaltrials.org/static/documentation/aact_schema.png' => 'schema.png',
        'https://aact.ctti-clinicaltrials.org/definitions.csv' => 'data_dictionary.csv'
      }
    end

    def root_dir
      "#{Rails.public_path}/static"
    end

    def base_folder(schema = 'ctgov')
      return "#{root_dir}/ctgov_archive_" if schema =~ /archive/

      "#{root_dir}/"
    end

    def static_copies_directory(schema = 'ctgov')
      folder = "#{base_folder(schema)}static_db_copies"
      if created_first_day_of_month? Time.zone.now.strftime('%Y%m%d')
        "#{folder}/monthly"
      else
        "#{folder}/daily"
      end
    end

    def flat_files_directory(schema = '')
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
      Roo::Spreadsheet.open("#{root_dir}/documentation/aact_data_definitions.xlsx")
    rescue StandardError
      # No guarantee the file exists
    end

    def get_dump_file_from(static_file)
      return static_file if `file --brief --mime-type "#{static_file}"` == "application/octet-stream\n"

      return unless `file --brief --mime-type "#{static_file}"` == "application/zip\n"

      Zip::File.open(static_file) do |zipfile|
        zipfile.each do |file|
          return file if file.name == 'postgres_data.dmp'
        end
      end
    end

    def created_first_day_of_month?(str)
      day = str.split('/')[1]
      day == '01'
    end

    # package files for archival purposes
    def save_static_copy(dump_filename, schema_name = "ctgov")
      # gather files into a directory
      documentation_files.each do |url, filename|
        `wget "#{url}" -q -O #{dump_directory}/#{filename}`
      end

      # generate the filename
      date_stamp = Time.zone.now.strftime('%Y%m%d')

      zip_file_name = "#{dump_directory}/#{date_stamp}_clinical_trials_#{schema_name}.zip"
      # zip files
      File.delete(zip_file_name) if File.exist?(zip_file_name)
      `zip -j #{zip_file_name} #{documentation_files.values.map { |k| "#{dump_directory}/#{k}" }.join(' ')} #{dump_filename}`

      # upload file to the cloud
      FileRecord.post('snapshot', zip_file_name)
      File.delete(zip_file_name) if File.exist?(zip_file_name)
    end
  end
end
