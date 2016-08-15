namespace :import do
  namespace :full do
    task run: :environment do
      if Date.today.day == 1
        load_event = ClinicalTrials::LoadEvent.create(
          event_type: 'full_import'
        )

        Study.destroy_all

        client = ClinicalTrials::Client.new
        client.download_xml_files
        client.populate_studies

        load_event.complete

        StudyValidator.new.validate_studies
        LoadMailer.send_notification(load_event)
      else
        puts "Not the first of the month - not running full import"
      end
    end
  end
end
