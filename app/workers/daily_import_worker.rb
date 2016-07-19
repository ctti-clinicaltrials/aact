class DailyImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'daily_import'

  def perform(days_back)
    load_event = ClinicalTrials::LoadEvent.create(
      event_type: 'daily_import'
    )

    nct_ids_to_be_updated_or_added = ClinicalTrials::RssReader.new(days_back: days_back).get_changed_nct_ids
    $stderr.puts "Number of studies changed or added: #{nct_ids_to_be_updated_or_added.count}"
    load_event.update(description: "Number of studies changed or added: #{nct_ids_to_be_updated_or_added.count}")
    StudyUpdater.new.update_studies(nct_ids: nct_ids_to_be_updated_or_added)


    load_event.complete
  end
end
