class PagesController < ApplicationController
  def home
    @lastUpdate = ClinicalTrials::LoadEvent.last.try(:updated_at)
    @snapshot_exports="#{ENV['FILESERVER_ENDPOINT']}/snapshots"
  end

  def snapshots
    @snapshot_exports="#{ENV['FILESERVER_ENDPOINT']}/snapshots"
  end

  def snapshot_archive
    @snapshot_exports="#{ENV['FILESERVER_ENDPOINT']}/snapshots"
    @files=ClinicalTrials::FileManager.snapshot_files
  end

  def pipe_delimited
    @pipe_exports="#{ENV['FILESERVER_ENDPOINT']}/csv_pipe_exports"
  end

  def points_to_consider
    @analyst_guide="#{ENV['FILESERVER_ENDPOINT']}/documentation/analyst_guide.png"
    @schema_diagram="#{ENV['FILESERVER_ENDPOINT']}/documentation/aact_schema.png"
    @data_dictionary="#{ENV['FILESERVER_ENDPOINT']}/documentation/data_dictionary.png"
  end

  def download_aact
    #code
  end

  def learn_more
    @schema_diagram="#{ENV['FILESERVER_ENDPOINT']}/documentation/aact_schema.png"
    @data_dictionary="#{ENV['FILESERVER_ENDPOINT']}/documentation/data_dictionary.png"
  end

  def sanity_check
    @sanity_check_report = SanityCheck.last.report
  end
end
