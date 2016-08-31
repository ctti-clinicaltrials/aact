class PagesController < ApplicationController
  def home
    @lastUpdate = ClinicalTrials::LoadEvent.last.try(:updated_at)
  end

  def snapshot_archive
    @snapshots = Date.today..90.days.ago
  end

  def pipe_delimited
    #code
  end

  def points_to_consider
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
