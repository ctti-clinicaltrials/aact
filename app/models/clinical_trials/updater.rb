module ClinicalTrials
  class Updater
    attr_reader :params, :load_event, :client, :study_counter

    def initialize(args={})
      @params=args
      type=(@params[:event_type] ? @params[:event_type] : 'incremental')
      @load_event = ClinicalTrials::LoadEvent.create({:event_type=>type,:status=>'running',:description=>'',:problems=>''})
      @client = ClinicalTrials::Client.new(updater: self)
      @study_counter={:should_add=>0,:should_change=>0,:add=>0,:change=>0,:count_down=>0}
      self
    end

    def run
      if @load_event.event_type=='full'
        full
      else
        incremental
      end
    end

    def full
      log('begin ...')
      truncate_tables
      download_xml_file_from_ctgov
      populate_studies
      run_sanity_checks
      export_snapshots
      export_tables
      send_notification
      @load_event.complete({:new_studies=> Study.count})
    end

    def incremental
      begin
        log("begin ...")
        days_back=(@params[:days_back] ? @params[:days_back] : 4)
        ids = ClinicalTrials::RssReader.new(days_back: days_back).get_changed_nct_ids
        log_expected_counts(ids)
        update_studies(ids[0..200])  # TODO  Take this restriction out - just for initial verification that it works on server
        run_sanity_checks
        export_snapshots
        export_tables
        send_notification
        @load_event.complete({:new_studies=> @study_counter[:add], :changed_studies => @study_counter[:change]})
      rescue StandardError => e
        @load_event.add_problem({:name=>"Error encountered in incremental update.",:first_backtrace_line=>  "#{e.backtrace.to_s}"})
        @load_event.complete({:status=> 'failed'})
        LoadMailer.send_notifications(@load_event)
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
      @study_counter[:count_down]=nct_ids.size
      nct_ids.each {|nct_id|
        begin
          refresh_study(nct_id)
          show_progress(nct_id)
        rescue StandardError => e
          @load_event.add_problem({:name=> "error #{nct_id}", :first_backtrace_line=>e.backtrace.to_s})
          @load_event.add_problem({:name=> "occurred after processing #{countdown} studies", :first_backtrace_line=>''})
          next
        end
      }
      self
    end

    private

    def download_xml_file_from_ctgov
      log("download xml file(s)...")
      @client.download_xml_files
    end

    def populate_studies
      log("populate studies...")
      @client.populate_studies
    end

    def run_sanity_checks
      log("sanity check...")
      SanityCheck.run
    end

    def export_tables
      if !@params[:create_snapshots]==false
        log("exporting tables...")
        TableExporter.new.run
      end
    end

    def export_snapshots
      log("exporting db snapshot...")
      #Snapshotter.new.run
    end

    def truncate_tables
      Updater.loadable_tables.each { |table|
        log("  truncate #{table}")
        ActiveRecord::Base.connection.truncate(table)
      }
    end

    def refresh_study(nct_id)
      old_xml_record = StudyXmlRecord.where(nct_id: nct_id) #should only be one
      old_study=Study.where(nct_id: nct_id)    #should only be one
      increment_study_counter(old_study.size)
      old_xml_record.each{|old| old.destroy }  # but remove all... just in case
      old_study.each{|old| old.destroy }

      new_xml=@client.get_xml_for(nct_id)
      StudyXmlRecord.create(:nct_id=>nct_id,:content=>new_xml)
      Study.new({ xml: new_xml, nct_id: nct_id }).create
    end

    def send_notification
      log("send email notification...")
      LoadMailer.send_notifications(@load_event)
    end

    def log_expected_counts(ids)
      @study_counter[:should_change] = (Study.pluck(:nct_id) & ids).count
      @study_counter[:should_add] = (ids.count - should_change_count)
      log("should change: #{@study_counter[:should_change]};  should add: #{@study_counter[:should_add]}")
    end

    def log(msg)
      @load_event.log(msg)
    end

    def show_progress(nct_id)
      @study_counts[:count_down]-=1
      @load_event.show_progress(@study_counts[:count_down], nct_id)
    end

    def increment_study_counter(study_exists)
      if study_exists > 0
        @study_counter[:change]+=1
      else
        @study_counter[:add]+=1
      end
    end
  end
end
