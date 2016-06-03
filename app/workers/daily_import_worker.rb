class DailyImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'daily_import'

  def perform
    client = ClinicalTrials::Client.new
    client.import_xml_files
  end
end
