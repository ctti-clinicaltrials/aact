module ClinicalTrials
  class Updater
    attr_reader :load_type, :errors, :progress_log, :client

    def initialize
      @errors = []
      @progress_log=[]
    end

    def full(params={})
      @load_type='Full'
      log('Full Update: begin...')
      load_event = ClinicalTrials::LoadEvent.start('full_update')
      truncate_tables
      client = ClinicalTrials::Client.new
      log("download xml files...")
      client.download_xml_files
      log("populate studies...")
      client.populate_studies
      log("sanity check...")
      SanityCheck.run
      log("send email notification...")
      if !params[:create_snapshots]==false
        log("exporting db snapshot...")
        TableExporter.new.run
      end
      #LoadMailer.send_notifications(load_event, client.errors)
      load_event.complete({:errors=>errors, :description=>@progress_log,:new_studies=> Study.count})
    end

    def incremental(params={})
      @load_type='Incremental'
      @progress_log=''
      begin
        log("begin...")
        days_back=(params[:days_back] ? params[:days_back] : 3)
        load_event = ClinicalTrials::LoadEvent.start('incremental_update')
        ids = ClinicalTrials::RssReader.new(days_back: days_back).get_changed_nct_ids
        changed_count = (Study.pluck(:nct_id) & ids).count
        new_count = ids.count - changed_count
        log("changed: #{changed_count}  added: #{new_count}")

        update_studies(ids)
        log("sanity check...")
        SanityCheck.run
        log("load notification...")
        if !params[:create_snapshots]==false
          log("exporting db snapshot...")
          TableExporter.new.run
        end
        LoadMailer.send_notifications(load_event, errors)
        load_event.complete({:errors=>errors, :description=>@progress_log,:new_studies=> new_count, :changed_studies => changed_count})
      rescue StandardError => e
        log("Error encountered in incremental update...  #{e}")
        @errors << {:name => 'An error was raised during the load.', :first_backtrace_line => e}
        load_event.complete({:status=> 'failed',:description=>@progress_log})
        LoadMailer.send_notifications(load_event, errors)
        raise e
      end
    end

    def self.loadable_tables()
      blacklist = %w(
        schema_migrations
        load_events
        sanity_checks
        statistics
        study_xml_records
      )
      ActiveRecord::Base.connection.tables.reject{|table|blacklist.include?(table)}
    end

    def update_studies(nct_ids)
      @client = ClinicalTrials::Client.new
      study_counter=0
      nct_ids.each {|nct_id|
        begin
          refresh_study(nct_id)
          study_counter=study_counter + 1
          show_progress(study_counter,nct_id)
        rescue StandardError => e
          existing_error = @errors.find do |err|
            (err[:name] == e) && (err[:first_backtrace_line] == e.backtrace.first)
          end
          if existing_error.present?
            existing_error[:count] += 1
          else
            @errors << { :name => e, :first_backtrace_line => e.backtrace.first, :count => 0 }
          end
          next
        end
      }
      self
    end

    private

    def log(msg)
      stamped_message="    #{load_type}: #{Time.now} #{msg}"
      @progress_log << msg
      $stdout.puts stamped_message
      $stdout.flush
    end

    def truncate_tables
      log("   #{Time.now} truncate tables...")
      Updater.loadable_tables.each { |table|
        log("  truncate #{table}")
        ActiveRecord::Base.connection.truncate(table)
      }
    end

    def refresh_study(nct_id)
      old_xml_records = StudyXmlRecord.where(nct_id: nct_id) #should only be one
      old_studies=Study.where(nct_id: nct_id)    #should only be one
      old_xml_records.each{|old| old.destroy }
      old_studies.each{|old| old.destroy }

      new_xml=@client.get_xml_for(nct_id)
      StudyXmlRecord.create(:nct_id=>nct_id,:content=>new_xml)
      Study.create({ xml: new_xml, nct_id: nct_id })
      check_study=Study.where('nct_id=?',nct_id)
    end

    def show_progress(study_counter,nct_id)
      if study_counter % 100 == 0
        $stdout.puts "#{study_counter} (#{nct_id})"
        $stdout.flush
      else
        print '.'
        $stdout.flush
      end
    end

  end
end
