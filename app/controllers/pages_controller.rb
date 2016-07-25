class PagesController < ApplicationController
  def home
    @lastUpdate = ClinicalTrials::LoadEvent.last.updated_at
  end

  def snapshot_archive
    @snapshots = Date.today..90.days.ago
  end
end
