namespace :import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      if ![1,4,8,12,16,22,26,30].include? Date.today.day || args[:force]
        begin
          $stdout.puts "Daily Import: #{Time.now} begin..."
          $stdout.flush
          load_event = ClinicalTrials::LoadEvent.create(event_type: 'daily_import')
          nct_ids_to_be_updated_or_added = ClinicalTrials::RssReader.new(days_back: args[:days_back]).get_changed_nct_ids
          changed_studies_count = (Study.pluck(:nct_id) & nct_ids_to_be_updated_or_added).count
          new_studies_count = nct_ids_to_be_updated_or_added.count - changed_studies_count
          $stdout.puts "Number of studies to be changed or added: #{nct_ids_to_be_updated_or_added.count}"
          $stdout.flush

          $stdout.puts "Daily Import: #{Time.now}  update studies..."
          $stdout.flush
          updater = StudyUpdater.new.update_studies(nct_ids: nct_ids_to_be_updated_or_added)
          load_event.update(new_studies: new_studies_count, changed_studies: changed_studies_count)
          load_event.complete

          $stdout.puts "Daily Import: #{Time.now}  sanity check..."
          $stdout.flush
          SanityCheck.run
          #$stdout.puts 'Daily Import: StudyValidator...'
          #StudyValidator.new.validate_studies
          $stdout.puts "Daily Import: #{Time.now}  load notification..."
          $stdout.flush
          LoadMailer.send_notifications(load_event, updater.errors)
        rescue StandardError => e
          $stdout.puts "Error encountered in daily load...  #{e}"
          updater.errors << {:name => 'An error was raised during the load.', :first_backtrace_line => e}
          LoadMailer.send_notifications(load_event, updater.errors)
          raise e
        end
      else
        $stdout.puts "Daily Import:  Day is #{Date.today.day} so full import will run. Daily job skipped."
        $stdout.flush
      end
    end
  end
end

