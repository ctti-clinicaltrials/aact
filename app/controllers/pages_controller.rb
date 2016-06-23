class PagesController < ApplicationController
  def home
    @studyCount = Study.count
    @lastUpdate = ClinicalTrials::LoadEvent.last.updated_at
  end
end
