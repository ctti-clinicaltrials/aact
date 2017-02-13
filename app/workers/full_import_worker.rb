class FullImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'full_import'

  def perform
    load_event = LoadEvent.create(
      event_type: 'full_import'
    )

    client = ClinicalTrials::Client.new
    client.download_xml_files
    client.populate_studies

    load_event.complete
  end
end

