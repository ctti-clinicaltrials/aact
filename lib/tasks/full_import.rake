namespace :import do
  namespace :full do
    #  type can be 'force' (run full load no matter the day)
    #  or 'restart' (restart the previously launched full load)
    task :run, [:type] => :environment do |t, args|
      load_event = ClinicalTrials::LoadEvent.create(event_type: 'full_import')
      client = ClinicalTrials::Client.new
      if args[:type]=='restart'
        puts "Restarting full import..."
        total_count=StudyXmlRecord.count
        already_loaded=StudyXmlRecord.count(:created_study_at)
        puts "Skipping those already loaded: #{already_loaded} of #{total_count}"
        client.restart_populate_studies
      else
        if Date.today.day ==1 || args[:type]=='force'
          puts "Starting full import from beginning..."
          all_tables = ActiveRecord::Base.connection.tables
          blacklist = %w(
             load_events
             sanity_checks
             schema_migrations
             stat_manager
             statistics
             use_cases
             use_case_attachments
          )
          puts "truncate tables..."
          tables_to_truncate = all_tables.reject {|table| blacklist.include?(table)}
          tables_to_truncate.each {|table| ActiveRecord::Base.connection.truncate(table)}
          puts "download xml file..."
          client.download_xml_files
          puts "start populating studies..."
          client.populate_studies
        end
      end

      load_event.complete

      SanityCheck.run
      StudyValidator.new.validate_studies
      LoadMailer.send_notifications(load_event, client.errors)
    end
  end
end
