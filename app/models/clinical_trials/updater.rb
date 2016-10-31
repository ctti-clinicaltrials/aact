module ClinicalTrials
  class Updater
    attr_reader :params, :load_event, :client, :study_counts, :download_file_name

    def initialize(params={})
      @params=params
      type=(params[:event_type] ? params[:event_type] : 'incremental')
      @client = ClinicalTrials::Client.new
      @load_event = ClinicalTrials::LoadEvent.create({:event_type=>type,:status=>'running',:description=>'',:problems=>''})
      @study_counts={:should_add=>0,:should_change=>0,:add=>0,:change=>0,:count_down=>0}
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
      @download_file_name = "ctgov_#{Time.now.strftime("%Y%m%d%H")}.zip" if @download_file_name.nil?
      log('begin ...')
      truncate_tables
      download_xml_file
      populate_xml_table
      create_studies
      run_sanity_checks
      export_tables
      send_notification
      @load_event.complete({:new_studies=> Study.count})
    end

    def incremental
      log("begin ...")
      days_back=(@params[:days_back] ? @params[:days_back] : 1)
      log("finding studies changed in past #{days_back} days...")
      ids = ClinicalTrials::RssReader.new(days_back: days_back).get_changed_nct_ids
      log("found #{ids.size} studies that have changed")
      set_expected_counts(ids)
      update_studies(ids)
      run_sanity_checks
      export_tables
      log_actual_counts
      @load_event.complete({:new_studies=> @study_counts[:add], :changed_studies => @study_counts[:change]})
      send_notification
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

    def set_count_down(sum)
      @study_counts[:count_down]=sum
    end

    def update_studies(nct_ids)
      log('update_studies...')
      set_count_down(nct_ids.size)
      nct_ids.each {|nct_id|
        refresh_study(nct_id)
        decrement_count_down
        show_progress(nct_id,'refreshing study')
      }
      self
    end

    def log(msg)
      @load_event.log(msg)
    end

    def show_progress(nct_id,action)
      @load_event.log("#{action}: #{@study_counts[:count_down]} (#{nct_id})")
    end

    def decrement_count_down
      @study_counts[:count_down]-=1
    end

    def increment_study_counts(study_exists)
      if study_exists > 0
        @study_counts[:change]+=1
      else
        @study_counts[:add]+=1
      end
    end

    def download_xml_file
      set_download_file_name({:download_file_name=>"ctgov_#{Time.now.strftime("%Y%m%d%H")}.zip"})
      log("download xml file...#{@download_file_name}")
      @client.download_xml_file
    end

    def populate_xml_table
      @download_file ||= ClinicalTrials::FileManager.get_file({:directory_name=>'xml_downloads',:file_name=>@download_file_name})
      log("populate xml table...")
      @client.populate_xml_table
    end

    def create_studies
      log("create studies...")
      @client.create_studies
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

    def truncate_tables
      Updater.loadable_tables.each { |table| ActiveRecord::Base.connection.truncate(table) }
      ActiveRecord::Base.connection.truncate('study_xml_records') unless should_rerun?
    end

    def should_rerun?
      @params[:rerun]==true && StudyXmlRecord.not_yet_loaded.size > 0
    end

    def refresh_study(nct_id)
      old_xml_record = StudyXmlRecord.where(nct_id: nct_id) #should only be one
      old_study=Study.where(nct_id: nct_id)    #should only be one
      increment_study_counts(old_study.size)
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

    def set_expected_counts(ids)
      @study_counts[:should_change] = (Study.pluck(:nct_id) & ids).count
      @study_counts[:should_add]    = (ids.count - @study_counts[:should_change])
      log("should change: #{@study_counts[:should_change]};  should add: #{@study_counts[:should_add]}\n")
    end

    def log_actual_counts
      log("should change: #{@study_counts[:change]};  should add: #{@study_counts[:add]}\n")
    end
  end
end
