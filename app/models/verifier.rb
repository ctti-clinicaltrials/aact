class Verifier < ActiveRecord::Base
<<<<<<< HEAD
  def self.alert_admins_about_differences
    admin_emails = ENV.fetch(Admin::User.admin_emails, "").split(",")
    admin_emails.each {|admin_email| Notifier.report_diff(admin_email).deliver_now}
  end

  def get_source_from_file(file_path="#{Util::FileManager.new.study_statistics_directory}/verifier_source_ctgov.json")
    file = File.read(file_path)
    self.update(source: JSON.parse(file))
  end

  def self.refresh(params={load_event_id: nil})
=======
  def self.refresh(params={schema: 'ctgov', load_event_id: nil})
>>>>>>> 7d369ae4676a63e6d765e3e10a0ebd7a07c7f4ad
    begin
      api_json =  ClinicalTrialsApi.study_statistics
      verifier = Verifier.create(source: api_json.dig('StudyStatistics', "ElmtDefs", "Study"), load_event_id: params[:load_event_id])
      verifier.verify
    rescue => error
      msg="#{error.message} (#{error.class} #{error.backtrace}"
      ErrorLog.error(msg)
      Airbrake.notify(error)
    end
  end

  def verify
    return unless self.source
    diff = []

    comparisons = Support::StudyStatisticsComparison.all
    total = comparisons.count
    comparisons.each do |comparison|
      begin
        print "#{total} verifying: #{comparison.ctgov_selector}"
        entry = comparison.compare(source)
        if entry[:source_instances] != entry[:destination_instances] || entry[:source_unique_values] != entry[:destination_unique_values]
          puts " BAD".red
          diff << entry
        else
          puts " GOOD".green
        end
        update(differences: diff)
        total -= 1
      rescue => error
        msg="#{error.message} (#{error.class} #{error.backtrace}"
        puts msg
        ErrorLog.error(msg)
        Airbrake.notify(error)
        next
      end
    end

    self.update(last_run: Time.now)

    return diff
  end  
end