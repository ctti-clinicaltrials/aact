module ClinicalTrials
  class Updater
    def daily(params={})
      begin
        days_back=(params[:days_back] ? params[:days_back] : 7)
        log("Daily Update: #{Time.now} begin...")
        load_event = ClinicalTrials::LoadEvent.create(event_type: 'daily_update',created_at: Time.now)
        ids_updated_or_added = ClinicalTrials::RssReader.new(days_back: days_back).get_changed_nct_ids
        changed_count = (Study.pluck(:nct_id) & ids_updated_or_added).count
        new_count = ids_updated_or_added.count - changed_count
        log("Daily Update: #{Time.now}  changed: #{changed_count}  added: #{new_count}")
        updater = StudyUpdater.new.update_studies(nct_ids: ids_updated_or_added)
        load_event.update(new_studies: new_count, changed_studies: changed_count)
        load_event.complete
        log("Daily Update: #{Time.now}  sanity check...")
        SanityCheck.run
        log("Daily Update: #{Time.now}  load notification...")
        LoadMailer.send_notifications(load_event, updater.errors)
      rescue StandardError => e
        log("Error encountered in daily update...  #{e}")
        updater.errors << {:name => 'An error was raised during the load.', :first_backtrace_line => e}
        LoadMailer.send_notifications(load_event, updater.errors)
        raise e
      end
    end

    def log(msg)
      $stdout.puts msg
      $stdout.flush
    end

  end
end
