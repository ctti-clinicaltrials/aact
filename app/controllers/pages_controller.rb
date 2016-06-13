class PagesController < ApplicationController
  def home
    @studyCount = Study.count
    @lastUpdate = ClinicalTrials::LoadEvent.last.updated_at.strftime("%B %d, %Y")
  end
end
