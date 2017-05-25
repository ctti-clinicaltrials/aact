class PagesController < ApplicationController
  def home
    @lastUpdate = LoadEvent.last.try(:updated_at)
    @snapshot_exports="#{ENV['FILESERVER_ENDPOINT']}/snapshots"
  end

  def snapshots
    @files=ClinicalTrials::FileManager.snapshot_files
    @most_recent=@files.last
  end

  def pipe_files
    @files=ClinicalTrials::FileManager.pipe_delimited_files
    @most_recent=@files.last
  end

  def points_to_consider
    @analyst_guide=ClinicalTrials::FileManager.analyst_guide
    @admin_schema_diagram=ClinicalTrials::FileManager.admin_schema_diagram
    @schema_diagram=ClinicalTrials::FileManager.schema_diagram
    @data_dictionary=ClinicalTrials::FileManager.data_dictionary
    @table_dictionary=ClinicalTrials::FileManager.table_dictionary
  end

  def learn_more
    @admin_schema_diagram=ClinicalTrials::FileManager.admin_schema_diagram
    @schema_diagram=ClinicalTrials::FileManager.schema_diagram
    @data_dictionary=ClinicalTrials::FileManager.data_dictionary
    @table_dictionary=ClinicalTrials::FileManager.table_dictionary
  end

  def schema
    @admin_schema_diagram=ClinicalTrials::FileManager.admin_schema_diagram
    @schema_diagram=ClinicalTrials::FileManager.schema_diagram
    @data_dictionary=ClinicalTrials::FileManager.data_dictionary
    @table_dictionary=ClinicalTrials::FileManager.table_dictionary
    @show_dictionary_link = true
  end

  def sanity_check
    @sanity_check_report = SanityCheck.last.report
  end

  def letsencrypt
     render text: "eovqiw5Ay5Oqo3ppiFr_b47uhEA0l9GhiJQwKekENIo.h4AET8S0L96XTM6tGuJQBD60-2rHKzZ4mlYzKl9Ay6A"
  end

end
