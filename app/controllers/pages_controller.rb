class PagesController < ApplicationController
  def home
    @lastUpdate = ClinicalTrials::LoadEvent.last.try(:updated_at)
    @snapshot_exports="#{ENV['FILESERVER_ENDPOINT']}/snapshots"
  end

  def snapshots
    #@snapshot_exports="#{ENV['FILESERVER_ENDPOINT']}/snapshots"
    @files=ClinicalTrials::FileManager.snapshot_files
    @most_recent=@files.last
  end

  def pipe_files
    #@pipe_exports="#{ENV['FILESERVER_ENDPOINT']}/csv_pipe_exports"
    @files=ClinicalTrials::FileManager.pipe_delimited_files
    @most_recent=@files.last
  end

  def points_to_consider
    @analyst_guide=ClinicalTrials::FileManager.analyst_guide
    @schema_diagram=ClinicalTrials::FileManager.schema_diagram
    @data_dictionary=ClinicalTrials::FileManager.data_dictionary
  end

  def learn_more
    @schema_diagram=ClinicalTrials::FileManager.schema_diagram
    @data_dictionary=ClinicalTrials::FileManager.data_dictionary
  end

  def schema
    @schema_diagram=ClinicalTrials::FileManager.schema_diagram
    @data_dictionary=ClinicalTrials::FileManager.data_dictionary
  end

  def sanity_check
    @sanity_check_report = SanityCheck.last.report
  end

end
