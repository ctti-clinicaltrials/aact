class PagesController < ApplicationController

  def snapshots
    @daily_files=Util::FilePresentationManager.daily_snapshot_files
    @archive_files=Util::FilePresentationManager.monthly_snapshot_files
  end

  def pipe_files
    @daily_files=Util::FilePresentationManager.daily_flat_files
    @archive_files=Util::FilePresentationManager.monthly_flat_files
  end

  def points_to_consider
    @admin_schema_diagram=Util::FilePresentationManager.admin_schema_diagram
    @schema_diagram=Util::FilePresentationManager.schema_diagram
    @data_dictionary=Util::FilePresentationManager.data_dictionary
    @table_dictionary=Util::FilePresentationManager.table_dictionary
  end

  def learn_more
    @admin_schema_diagram=Util::FilePresentationManager.admin_schema_diagram
    @schema_diagram=Util::FilePresentationManager.schema_diagram
    @data_dictionary=Util::FilePresentationManager.data_dictionary
    @table_dictionary=Util::FilePresentationManager.table_dictionary
  end

  def schema
    @admin_schema_diagram=Util::FilePresentationManager.admin_schema_diagram
    @schema_diagram=Util::FilePresentationManager.schema_diagram
    @data_dictionary=Util::FilePresentationManager.data_dictionary
    @table_dictionary=Util::FilePresentationManager.table_dictionary
    @show_dictionary_link = true
  end

  def sanity_check
    @sanity_check_report = Admin::SanityCheck.last.report
  end

end
