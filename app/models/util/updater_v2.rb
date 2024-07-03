module Util
  class UpdaterV2
    include SchemaSwitcher

    attr_reader :params, :schema

    def initialize(params = {})
      @params = params
      @type = (params[:event_type] || "incremental")
      @schema = params[:schema] || "ctgov"
    end


    def run_main_loop
      loop do
        now = TZInfo::Timezone.get("America/New_York").now
        if Support::LoadEvent.where("created_at > ?", now.beginning_of_day).count == 0
          execute
        else
          ActiveRecord::Base.logger = nil
          update_current_studies
        end
      end
    end
    

    def execute
      ActiveRecord::Base.logger = nil
      @step_count = 0
      create_load_event
      log("🚀🚀🚀 Execute Event for #{@schema} schema 🚀🚀🚀", false, true)

      run_step("Remove Contraints") { db_mgr.remove_constraints }

      run_step("Update Studies") do
        studies = StudyDownloader.download_recently_updated
        # TODO: add batch processing if there are too many studies downloaded
        process(studies)
      end

      run_step("Add Constraints") { db_mgr.add_constraints }
      run_step("Compare Counts", skipped = true)
      run_step("Study Searches", skipped = true)

      run_step("Update Mesh Terms and Headings") do
        log("populating mesh terms from file...", false)
        MeshTerm.populate_from_file
        log("populating mesh headings from file...", false)
        MeshHeading.populate_from_file
        set_downcase_terms
      end

      run_step("Sanity Checks") { @load_event.run_sanity_checks(@schema) }

      if @load_event.sanity_checks.count == 0
        run_step("Take DB Snapshot") { take_snapshot }
        run_step("Refresh Public DB") { db_mgr.refresh_public_db }
        run_step("Create Flat Files") { create_flat_files }
        log("🏁🏁🏁 Execute Event Completed 🏁🏁🏁", false)
        @load_event.update({ status: "complete", completed_at: Time.now})
      else
        log("🛑 Execution Stopped: Discrepancies Found During Sanity Checks")
        @load_event.update({ status: "stopped", completed_at: Time.now})
      end

    rescue => e
      @load_event.update({ status: "error"}) 
      @load_event.update({ problems: "#{e.message}\n\n#{e.backtrace.join("\n")}" }) 
      log("⛔ Execute Stopped at Step #{@step_count} because of #{e.message}", log_event = false)
    end

    private
    
    def worker
      @worker ||= StudyJsonRecord::Worker.new
    end

    def db_mgr
      # makes it "singleton-like" inside the class
      @db_mgr ||= Util::DbManager.new(event: @load_event, schema: @schema)
    end

    def update_current_studies(count=1000)
      # TODO: review why setting the search path is necessary
      db_mgr.remove_constraints
      with_search_path('ctgov, support, public') do
        list = Study.order(updated_at: :asc).limit(count).pluck(:nct_id)
        studies = StudyDownloader.download(list)
        process(studies)
      end
    end


    def process(studies)
      worker.process(studies.count, studies)
      CalculatedValue.populate_for(studies)
    end

    def set_downcase_terms
      log("setting downcase mesh terms...", false)
      con=ActiveRecord::Base.connection
      con.execute("SET search_path TO #{@schema}")
      #  save a lowercase version of MeSH terms so they can be found without worrying about case
      con.execute("UPDATE browse_conditions SET downcase_mesh_term=lower(mesh_term);")
      con.execute("UPDATE browse_interventions SET downcase_mesh_term=lower(mesh_term);")
      con.execute("UPDATE keywords SET downcase_name=lower(name);")
      con.execute("UPDATE conditions SET downcase_name=lower(name);")
    end

    def take_snapshot
      log("dumping database...", false)
      filename = db_mgr.dump_database

      log("zipping and updloading db dump to cloud...", false)
      Util::FileManager.new.save_static_copy(filename, @schema)
      rescue StandardError => e
        @load_event.add_problem("#{e.message} (#{e.class} #{e.backtrace}")
    end

    def create_flat_files
      log("working hard on creating flat files...", false)
      Util::TableExporter.new([], @schema).run(delimiter: '|')
    end

    def create_load_event
      @load_event = Support::LoadEvent.create({
        event_type: @type,
        status: "running",
        description: "🛠️  Execute Load Event for #{@schema} schema\n",
        problems: "" 
      })
    end


    def run_step(description, skipped = false)
      @step_count += 1
      start_time = Time.zone.now
      if skipped
        log("Step #{@step_count}: ⏭️  #{description}")
        puts "------------------------------------------------------------------"
      else
        puts "[#{timestamp}] - Step #{@step_count}: ⏳ #{description}"
        yield if block_given?
        end_time = Time.zone.now
        duration = end_time - start_time
        log("Step #{@step_count}: ✅ #{description} (#{duration.round(2)} sec)")
        puts "------------------------------------------------------------------"
      end
    end


    def log(msg, event_log = true, day_only = false)
      formatted_message = "[#{timestamp(day_only)}] - #{msg}\n"
      @load_event.log(msg) if event_log
      puts formatted_message
    end

    def timestamp(day_only = false)
      if day_only
        Time.zone.now.strftime("%Y-%m-%d")
      else
        Time.zone.now.strftime("%I:%M:%S %p")
      end
    end
  end
end
