module ClinicalTrials
  class Updater

    def full(params={})
      log('Full Update: begin...')
      load_event = ClinicalTrials::LoadEvent.create( event_type: 'full_update',created_at: Time.now)
      truncate_tables
      client = ClinicalTrials::Client.new
      log("Full Update: #{Time.now}  download xml files...")
      client.download_xml_files
      log("Full Update: #{Time.now}  populate studies...")
      client.populate_studies
      load_event.update(new_studies: Study.count, changed_studies: 0)
      load_event.complete
      log("Full Update: #{Time.now}  sanity check...")
      SanityCheck.run
      log("Full Update: #{Time.now}  send email notification...")
      LoadMailer.send_notifications(load_event, client.errors)
      if !params[:create_snapshots]==false
        log("Full Update: #{Time.now}  exporting db snapshot...")
        TableExporter.new.run
      end
    end

    def incremental(params={})
      begin
        days_back=(params[:days_back] ? params[:days_back] : 7)
        log("Incremental Update: #{Time.now} begin...")
        load_event = ClinicalTrials::LoadEvent.create(event_type: 'incremental_update',created_at: Time.now)
        ids_updated_or_added = ClinicalTrials::RssReader.new(days_back: days_back).get_changed_nct_ids
        changed_count = (Study.pluck(:nct_id) & ids_updated_or_added).count
        new_count = ids_updated_or_added.count - changed_count
        log("Incremental Update: #{Time.now}  changed: #{changed_count}  added: #{new_count}")
        updater = StudyUpdater.new.update_studies(nct_ids: ids_updated_or_added)
        load_event.update(new_studies: new_count, changed_studies: changed_count)
        load_event.complete
        log("Incremental Update: #{Time.now}  sanity check...")
        SanityCheck.run
        log("Incremental Update: #{Time.now}  load notification...")
        if !params[:create_snapshots]==false
          log("Incremental Update: #{Time.now}  exporting db snapshot...")
          TableExporter.new.run
        end
        LoadMailer.send_notifications(load_event, updater.errors)
      rescue StandardError => e
        log("Error encountered in incremental update...  #{e}")
        updater.errors << {:name => 'An error was raised during the load.', :first_backtrace_line => e}
        LoadMailer.send_notifications(load_event, updater.errors)
        raise e
      end
    end

    def truncate_tables
      log('Full Update: truncate tables...')
      Updater.loadable_tables.each do |table|
        log("  truncate #{table}")
        ActiveRecord::Base.connection.truncate(table)
      end
    end

    def log(msg)
      $stdout.puts msg
      $stdout.flush
    end

    def self.loadable_tables
      blacklist = %w(
          schema_migrations
          load_events
          sanity_checks
          statistics
          study_xml_records
      )
      ActiveRecord::Base.connection.tables.reject{|table|blacklist.include?(table)}
    end
  end
end
