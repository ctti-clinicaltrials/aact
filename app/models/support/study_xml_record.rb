module Support
  class StudyXmlRecord < Support::SupportBase
    BASE_URL = 'https://clinicaltrials.gov'
    POOL_SIZE = 30

    belongs_to :study, foreign_key: "nct_id"

    def self.incremental
      t = Time.now
      studies = ClinicalTrialsApi.all.map{|k| k[:id] }
      print "GET all studies #{Time.now - t}"

      current = Study.pluck(:nct_id)
      to_add = studies - current

      total = to_add.length
      total_time = 0
      stime = Time.now

      to_add.each_with_index do |id, idx|
        t = update_study(id)
        total_time += t
        avg_time = total_time / (idx + 1)
        remaining = (total - idx - 1) * avg_time
        puts "#{total - idx} #{id} #{t} #{htime(total_time)} #{htime(remaining)}"
      end

      time = Time.now - stime
      ActiveRecord::Base.logger = logger
      puts "Time: #{time} avg: #{time / total}"
    end

    def self.not_yet_loaded(study_filter=nil)
      if study_filter
        where('created_study_at is null and nct_id like ?',"%#{study_filter}")
      else
        where('created_study_at is null')
      end
    end

    def self.download_all_studies
      `wget --header="Content-Type: application/zip" -O public/static/xml_downloads/studies.zip "https://clinicaltrials.gov/search?term=&resultsxml=true"`
      `unzip public/static/xml_downloads/studies.zip -d public/static/xml_downloads`
    end

    def self.download_xml_files(days_back: 1)
      reader = Util::RssReader.new(days_back: days_back)
      ids = (reader.get_changed_nct_ids + reader.get_added_nct_ids).uniq
      threads = []
      ids.each_slice(ids.length / POOL_SIZE) do |group|
        threads << Thread.new(group) do |g|
          g.each do |nct_id|
            url = "#{BASE_URL}/show/#{nct_id}?resultsxml=true"
            content = Faraday.get(url).body
            filename = "public/static/xml_downloads/#{nct_id}.xml"
            FileUtils.rm_f(filename)
            File.write(filename, content.force_encoding("UTF-8"))
            puts "complete #{nct_id}"
          end
        end
      end
      threads.map{|t| t.join }

      total = ids.length
      total_time = 0
      stime = Time.now

      ids.each_with_index do |id, idx|
        t = update_study(id)
        total_time += t
        avg_time = total_time / (idx + 1)
        remaining = (total - idx - 1) * avg_time
        puts "#{total - idx} #{id} #{t} #{htime(total_time)} #{htime(remaining)}"
      end

      time = Time.now - stime
      ActiveRecord::Base.logger = logger
      puts "Time: #{time} avg: #{time / total}"
    end

    def self.remove_missing_studies(base: "public/static/xml_downloads")
      ids = Dir["#{base}/*.xml"].map{|k| k[/NCT\d+/] }
      to_remove = Study.pluck(:nct_id) - ids

      to_remove.each do |nct_id|
        study = Study.find_by(nct_id: nct_id)
        study.remove_study_data if study
      end
    end

    def self.add_missing_studies(base: "public/static/xml_downloads")
      ids = Dir["#{base}/*.xml"].map{|k| k[/NCT\d+/] }
      to_add = ids - Study.pluck(:nct_id)
      total = to_add.length

      to_add.each_with_index do |nct_id, idx|
        study = Study.find_by(nct_id: nct_id)
        study.remove_study_data if study
        t = update_study(nct_id)
        puts "#{total - idx} #{nct_id} #{t}"
      end
    end

    def self.to_update
      studies = ClinicalTrialsApi.all
      current = Hash[Study.pluck(:nct_id, :last_update_posted_date)]
      ids = studies.select do |entry|
        current_date = current[entry[:id]]
        current_date.nil? || entry[:updated] > current_date
      end
      ids.map{|k| k[:id] }
    end

    def self.update_studies
      logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil

      ids = to_update
      total = ids.length
      total_time = 0
      stime = Time.now

      ids.each_with_index do |id, idx|
        t = update_study(id)
        total_time += t
        avg_time = total_time / (idx + 1)
        remaining = (total - idx - 1) * avg_time
        puts "#{total - idx} #{id} #{t} #{htime(total_time)} #{htime(remaining)}"
      end

      time = Time.now - stime
      ActiveRecord::Base.logger = logger
      puts "Time: #{time} avg: #{time / total}"

      return ids
    end

    def self.htime(seconds)
      seconds = seconds.to_i
      hours = seconds / 3600
      seconds -= hours * 3600
      minutes = seconds / 60
      seconds -= minutes * 60
      "#{hours}:#{'%02i' % minutes}:#{'%02i' % seconds}"
    end

    def self.import_files(base: "public/static/xml_downloads")
      logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil

      ids = Dir["#{base}/*.xml"].map{|k| k[/NCT\d+/] }

      total = ids.length
      total_time = 0
      stime = Time.now

      ids.each_with_index do |id, idx|
        t = update_study(id)
        total_time += t
        avg_time = total_time / (idx + 1)
        remaining = (total - idx - 1) * avg_time
        puts "#{total - idx} #{id} #{t} #{htime(total_time)} #{htime(remaining)}"
      end

      time = Time.now - stime
      ActiveRecord::Base.logger = logger
      puts "Time: #{time} avg: #{time / total}"
    end

    def self.update_study(nct_id)
      begin
        stime = Time.now 
        record = StudyJsonRecord.find_by(nct_id: nct_id) || StudyJsonRecord.create(nct_id: nct_id, content: {})
        changed = record.update_from_api

        if record.blank? || record.content.blank? 
          record.destroy
        else 
          record.create_or_update_study
        end
      rescue => e
        ErrorLog.error(e)
        Airbrake.notify(e)
      end
      Time.now - stime
    end

    # 1. make api call
    # 2. verify response is xml and contains <clinical_study>
    def update_xml_from_api(tries: 5)
      url = "#{BASE_URL}/show/#{nct_id}?resultsxml=true"
      attempts = 0
      content = nil
      begin
        attempts += 1
        s = Time.now
        content = Faraday.get(url).body
        puts "  fetch #{Time.now - s}"
      rescue Faraday::ConnectionFailed
        return false if attempts > 5
        retry
      end
      xml = Nokogiri::XML(content)
      if xml.xpath('//clinical_study').length > 0
        self.content = content
        return false unless changed?
        return update content: content
      else
        # add error
      end
    end

    # 1. load xml file from disk
    # 2. verify file is xml and contains <clinical_study
    def update_xml_from_file(base='public/static/xml_downloads')
      filename = "#{base}/#{nct_id}.xml"
      if !File.exists?(filename)
        # update error
        return
      end

      content = File.read(filename)

      xml = Nokogiri::XML(content)
      if xml.xpath('//clinical_study').length > 0
        self.content = content
        return false unless changed?
        return update content: content
      else
        # add error
      end
    end

    def create_or_update_study
      study = Study.find_by(nct_id: nct_id)
      study.remove_study_data if study
      s = Time.now
      Study.new({ xml: Nokogiri::XML(content), nct_id: nct_id }).create
      # CalculatedValue.new.create_from(self).save
      puts "  insert-study #{Time.now - s}"
    end
  end
end

# NCT04698993, NCT04370834