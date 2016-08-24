namespace :import do
  namespace :full do
    task :run, [:force] => :environment do |t, args|
      if Date.today.day == 1 || args[:force]
        load_event = ClinicalTrials::LoadEvent.create(
          event_type: 'full_import'
        )

        all_tables = ActiveRecord::Base.connection.tables

        blacklist = %w(
          schema_migrations
          load_events
        )

        tables_to_truncate = all_tables.reject do |table|
          blacklist.include?(table)
        end

        tables_to_truncate.each do |table|
          ActiveRecord::Base.connection.truncate(table)
        end

        client = ClinicalTrials::Client.new
        client.download_xml_files
        client.populate_studies

        load_event.complete

        SanityCheck.run
        StudyValidator.new.validate_studies
        LoadMailer.send_notifications(load_event)
      else
        puts "Not the first of the month - not running full import"
      end
    end
  end
end
