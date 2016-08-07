namespace :import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      if Date.today.day != 1
        load_event = ClinicalTrials::LoadEvent.create(
          event_type: 'daily_import'
        )

        nct_ids_to_be_updated_or_added = ClinicalTrials::RssReader.new(days_back: args[:days_back]).get_changed_nct_ids
        $stderr.puts "Number of studies changed or added: #{nct_ids_to_be_updated_or_added.count}"
        load_event.update(description: "Number of studies changed or added: #{nct_ids_to_be_updated_or_added.count}")
        StudyUpdater.new.update_studies(nct_ids: nct_ids_to_be_updated_or_added)


        load_event.complete
      else
        puts "First of the month - running full import"
      end
    end
  end
end
