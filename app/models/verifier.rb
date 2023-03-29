class Verifier < ActiveRecord::Base
  def self.refresh(params={load_event_id: nil})
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