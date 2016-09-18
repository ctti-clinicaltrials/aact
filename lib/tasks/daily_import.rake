namespace :import do
  namespace :daily do
    task :run, [:days_back] => :environment do |t, args|
      if ![1,4,8,12,16,22,26,30].include? Date.today.day || args[:force]
        begin
          $stderr.puts 'Daily Import: begin...'
          load_event = ClinicalTrials::LoadEvent.create(event_type: 'daily_import')
          nct_ids_to_be_updated_or_added = ClinicalTrials::RssReader.new(days_back: args[:days_back]).get_changed_nct_ids
          changed_studies_count = (Study.pluck(:nct_id) & nct_ids_to_be_updated_or_added).count
          new_studies_count = nct_ids_to_be_updated_or_added.count - changed_studies_count
          $stderr.puts "Number of studies to be changed or added: #{nct_ids_to_be_updated_or_added.count}"

          $stderr.puts "Daily Import: #{Time.now}  update studies..."
          updater = StudyUpdater.new.update_studies(nct_ids: nct_ids_to_be_updated_or_added)
          load_event.update(new_studies: new_studies_count, changed_studies: changed_studies_count)
          load_event.complete

          $stderr.puts "Daily Import: #{Time.now}  sanity check..."
          SanityCheck.run
          #$stderr.puts 'Daily Import: StudyValidator...'
          #StudyValidator.new.validate_studies
          $stderr.puts "Daily Import: #{Time.now}  load notification..."
          LoadMailer.send_notifications(load_event, updater.errors)
        rescue StandardError => e
          $stderr.puts "Error encountered in daily load...  #{e}"
          updater.errors << {:name => 'An error was raised during the load.', :first_backtrace_line => e}
          LoadMailer.send_notifications(load_event, updater.errors)
          raise e
        end
      else
        puts "Daily Import:  Day is #{Date.today.day} so full import will run. Daily job skipped."
      end
    end
  end
end

