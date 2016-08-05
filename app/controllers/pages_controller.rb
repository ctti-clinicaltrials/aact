class PagesController < ApplicationController
  def home
    @lastUpdate = ClinicalTrials::LoadEvent.last.try(:updated_at)
  end

  def snapshot_archive
    @snapshots = Date.today..90.days.ago
  end

  def points_to_consider
    #code
  end

  def download_aact
    #code
  end

  def learn_more
    #code
  end

  def sanity_check
    @sanity_check_report = SanityCheck.last.report
  end
end
