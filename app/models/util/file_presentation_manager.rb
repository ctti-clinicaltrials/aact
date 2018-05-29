require 'action_view'
require 'open-uri'
include ActionView::Helpers::NumberHelper
module Util
  class FilePresentationManager

    def nlm_protocol_data_url
      "https://prsinfo.clinicaltrials.gov/definitions.html"
    end

    def nlm_results_data_url
      "https://prsinfo.clinicaltrials.gov/results_definitions.html"
    end

    def monthly_snapshot_files
      Util::FileManager.new.files_in('static_db_copies','monthly')
    end

    def daily_snapshot_files
      Util::FileManager.new.files_in('static_db_copies','daily')
    end

    def monthly_flat_files
      Util::FileManager.new.files_in('exported_files','monthly')
    end

    def daily_flat_files
      Util::FileManager.new.files_in('exported_files','daily')
    end

    def admin_schema_diagram
      "/static/documentation/aact_admin_schema.png"
    end

    def schema_diagram
      "/static/documentation/aact_schema.png"
    end

    def data_dictionary
      "/static/documentation/aact_data_definitions.xlsx"
    end

    def table_dictionary
      "/static/documentation/aact_tables.xlsx"
    end

  end
end
