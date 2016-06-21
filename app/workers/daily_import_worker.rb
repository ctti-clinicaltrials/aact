class DailyImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'daily_import'

  def perform
    client = ClinicalTrials::Client.new
    client.download_xml_files
    client.populate_studies
    Study.create_derived_values
  end
end
