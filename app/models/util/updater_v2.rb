module Util
  class UpdaterV2
    include SchemaSwitcher

    attr_reader :params, :schema

    def initialize(params = {})
      @params = params # #<Rake::TaskArguments schema: ctgov_v2>
      @type = (params[:event_type] || "incremental")
      @schema = params[:schema] || "ctgov_v2"
    end


    def run_main_loop
      loop do
        now = TZInfo::Timezone.get("America/New_York").now
        if Support::LoadEvent.where("created_at > ? AND description LIKE ?", now.beginning_of_day, "#{@schema}%").count == 0
          execute
        else
          ActiveRecord::Base.logger = nil
          db_mgr.remove_constraints
          update_old_studies
        end
      end
    end


    def update_old_studies(count=100)
      with_v2_schema do
        studies = Study.order(updated_at: :asc).limit(count)
        puts "refreshing #{studies.count} ctgov_v2 studies"
        studies.each do |study|
          puts "refresh #{study.nct_id} #{study.updated_at}"
          update_study(study.nct_id)
        end
      end
    end



    def execute

        log("#{@schema}: EXECUTE started")

        @load_event = Support::LoadEvent.create({
          event_type: @type,
          status: "running",
          description: "#{@schema}",
          problems: "" 
        })

        ActiveRecord::Base.logger = nil # why are we disabling logger here?

        # 1. remove constraings
        log("#{@schema}: removing constraints...")
        db_mgr.remove_constraints
        @load_event.log("1/11 removed constraints")

        # 2. update studies
        log("#{@schema}: updating studies...")
        StudyDownloader.download_recently_updated
        worker = StudyJsonRecord::Worker.new
        worker.import_all
        @load_event.log("2/11 updated studies")


        # 3. add constraints
        log("#{@schema}: adding constraints...")
        db_mgr.add_constraints
        @load_event.log("3/11 added constraints")


        # 4. comparing the counts from CT.gov to our database
        log("#{@schema}: comparing counts...")
        @load_event.log("4/11 skipped verification")


        # 5. run study searches
        log("#{@schema}: execute study search...")
        @load_event.log("5/11 skipped study searches")


        # 6. update calculated values
        log("#{@schema}: update calculated values...")
        CalculatedValue.populate(@schema)
        @load_event.log("6/11 updated calculated values")


        # 7. populate the meshterms and meshheadings
        log("#{@schema}: update mesh terms and headings...")
        MeshTerm.populate_from_file
        MeshHeading.populate_from_file
        set_downcase_terms
        @load_event.log("7/11 populated mesh terms")


        # 8. run sanity checks
        log("#{@schema}: run sanity checks...")
        @load_event.run_sanity_checks(@schema)
        @load_event.log("8/11 ran sanity checks")

        
        if @load_event.sanity_checks.count == 0
          puts "SANITY CHECKS PASSED"
          # 9. take snapshot
          log("#{@schema}: take snapshot...")
          with_v2_schema do
            take_snapshot
            @load_event.log("9/11 db snapshot created")
          end

          # 10. refresh public db
          log("#{@schema}: refresh public db...")
          db_mgr.refresh_public_db
          @load_event.log("10/11 refreshed public db")

          # 11. create flat files
          log("#{@schema}: creating flat files...")
          with_v2_schema do
            create_flat_files
            @load_event.log("11/11 created flat files")
          end
        end

        # 11. change the state of the load event from “running” to “complete”
        @load_event.update({ status: "complete", completed_at: Time.now})

        # 12. import study records
    rescue => e
      # set the load event status to "error"
      @load_event.update({ status: 'error'}) 
      # set the load event problems to the exception message
      @load_event.update({ problems: "#{e.message}\n\n#{e.backtrace.join("\n")}" }) 
      puts "EXECUTE ERROR: #{e.message}"
    end


    def update_studies

      to_update = StudyDownloader.download_recently_updated

      log("updating #{to_update.length} studies")

      # update studies
      total = to_update.length
      total_time = 0
      stime = Time.now
      to_update.each_with_index do |id, idx|
        t = update_study(id)
        total_time += t
        avg_time = total_time / (idx + 1)
        remaining = (total - idx - 1) * avg_time
        puts "#{total - idx} #{id} #{t} #{htime(total_time)} #{htime(remaining)}"
      end
      time = Time.now - stime
      puts "Time: #{time} avg: #{time / total}"
    end

    # TODO: Not called anywhere - verify that correct schema is being used
    def remove_studies
      # remove studies
      raise "Removing too many studies #{to_remove.count}" if  Study.count <= to_remove.count
      total = to_remove.length
      total_time = 0
      stime = Time.now
      to_remove.each_with_index do |id, idx|
        t = remove_study(id)
        total_time += t
        avg_time = total_time / (idx + 1)
        remaining = (total - idx - 1) * avg_time
        puts "#{total - idx} #{id} #{t} #{htime(total_time)} #{htime(remaining)}"
      end
    end


    def update_study(nct_id)
      stime = Time.now
      record = StudyJsonRecord.find_by(nct_id: nct_id, version: 2) || StudyJsonRecord.create(nct_id: nct_id, version: 2, content: {})
      if record.blank? || record.content.blank?
        record.destroy
      else
        StudyJsonRecord::Worker.new.process_study(nct_id)
      end

    Time.now - stime
    rescue => e
      Airbrake.notify(e)
      puts "An error occurred: #{e.message}"
    end


    # permanently remove study info from ctgov_v2 schema and study_json_records table
    def remove_study(id)
      stime = Time.now

      study = Study.find_by(nct_id: id)
      study.remove_study_data if study
      
      record = record = StudyJsonRecord.find_by(nct_id: id, version: '2')
      record.destroy if record

      return Time.now - stime
    end


    private

    def db_mgr
      # do we need to create new instance of DbManager every time?
      Util::DbManager.new(event: @load_event, schema: @schema)
    end

    def log(msg)
      puts "#{Time.zone.now}: #{msg}"
    end

    def set_downcase_terms
      log('setting downcase mesh terms...')
      con=ActiveRecord::Base.connection
      con.execute("SET search_path TO #{@schema}")
      #  save a lowercase version of MeSH terms so they can be found without worrying about case
      con.execute("UPDATE browse_conditions SET downcase_mesh_term=lower(mesh_term);")
      con.execute("UPDATE browse_interventions SET downcase_mesh_term=lower(mesh_term);")
      con.execute("UPDATE keywords SET downcase_name=lower(name);")
      con.execute("UPDATE conditions SET downcase_name=lower(name);")
    end

    def htime(seconds)
      seconds = seconds.to_i
      hours = seconds / 3600
      seconds -= hours * 3600
      minutes = seconds / 60
      seconds -= minutes * 60
      "#{hours}:#{'%02i' % minutes}:#{'%02i' % seconds}"
    end

    def take_snapshot
      log('dumping database...')
      filename = db_mgr.dump_database

      log('creating zipfile of database...')
      Util::FileManager.new.save_static_copy(filename, @schema)
      rescue StandardError => e
        @load_event.add_problem("#{e.message} (#{e.class} #{e.backtrace}")
    end

    def create_flat_files
      log('exporting tables as flat files...')
      Util::TableExporter.new([],'ctgov_v2').run(delimiter: '|')
    end

  end
end
