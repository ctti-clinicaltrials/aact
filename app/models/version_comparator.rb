class VersionComparator

  MODELS = [
    :study,
    :design_groups,
    :interventions,
    :detailed_description,
    :brief_summary,
    :design,
    :eligibility,
    :participant_flow,
    :baseline_measurements,
    :browse_conditions,
    :browse_interventions,
    :central_contacts,
    :conditions,
    :countries,
    :documents,
    :facilities,
    :id_information,
    :ipd_information_type,
    :keywords,
    :links,
    :milestones,
    :outcomes,
    :overall_officials,
    :design_outcomes,
    :provided_documents,
    :reported_events,
    :reported_event_totals,
    :responsible_party,
    :result_agreement,
    :result_contact,
    :study_references,
    :sponsors,
    :drop_withdrawals,
  ]

  def self.check(nct_id)
    ActiveRecord::Base.logger.level = Logger::ERROR

    StudyDownloader.download([nct_id], '1')
    StudyDownloader.download([nct_id], '2')

    # version 1
    record = StudyJsonRecord.find_by(nct_id: nct_id, version: "1")
    record = StudyDownloader.download([nct_id], '1') unless record
    record.preprocess
    v1 = record.data_collection

    # version 2
    record = StudyJsonRecord.find_by(nct_id: nct_id, version: "2")
    record = StudyDownloader.download([nct_id], '2') unless record
    processor = StudyJsonRecord::ProcessorV2.new(record.content)
    v2 = processor.parsed_data

    compare(v1, v2)
  end

  def self.full_check(model)
    # ClinicalTrialsApi.all.each do |study|
    File.readlines("#{Rails.root}/studies.csv").each do |nct_id|
      # nct_id = study[:id]
      nct_id = nct_id.strip
      puts "📜 #{nct_id}".purple
      result = check_model(nct_id, model)
      if !result
        `echo #{nct_id} >> #{Rails.root}/tmp/failed_#{model}.txt`
      end
    end
  end

  def self.check_model(nct_id, model)
    ActiveRecord::Base.logger.level = Logger::ERROR

    StudyDownloader.download([nct_id], '1')
    StudyDownloader.download([nct_id], '2')

    # version 1
    record = StudyJsonRecord.find_by(nct_id: nct_id, version: "1")
    record = StudyDownloader.download([nct_id], '1') unless record
    record.preprocess
    v1 = record.data_collection

    # version 2
    record = StudyJsonRecord.find_by(nct_id: nct_id, version: "2")
    record = StudyDownloader.download([nct_id], '2') unless record
    processor = StudyJsonRecord::ProcessorV2.new(record.content)
    v2 = processor.parsed_data

    case v1[model]
    when Array
      result = compare_models(model, v1[model], v2[model], true)
    when Hash
      result = compare_model(model, v1[model], v2[model], true)
    end
  end

  def self.compare(v1, v2)
    MODELS.each do |model|
      result = nil
      case v1[model]
      when Array
        result = compare_models(model, v1[model], v2[model])
      when Hash
        result = compare_model(model, v1[model], v2[model])
      end
      if result
        puts "✅ #{model}".green
      else
        puts "❌ #{model}".red
      end
    end
  end

  def self.compare_models(model, v1,v2, verbose=false)
    result = true # default to matching
    if v1&.length != v2&.length # number of rows is different
      puts "#{model}".blue if verbose
      puts "  row count mismatch".red if verbose
      return false 
    end
    v1.each_with_index do |row1, index|
      row2 = v2[index]
      result &&= compare_model(model, row1, row2, verbose)
    end
    return result
  end

  # compare two models, return true if they match & false if they don't match
  def self.compare_model(model, v1,v2, verbose=false)
    puts "#{model}".blue if verbose
    return true if v1.nil? && v2.nil? # neither creates entries

    result = [] # default to matching
    v1.each do |key, value|
      if v2.key?(key)
        # if key == :overall_status
        #   byebug
        # end
        if normalize(model, key, v2[key]) != normalize(model, key, value)
          if verbose
            puts "  #{key}"
            puts "   v1: #{value.inspect} #{value.class}"
            puts "   v2: #{v2[key].inspect} #{v2[key].class}"
          end
          result << false
        else
          result << true
        end
      else
        if verbose
          puts "  #{key}"
          puts "    v1: #{value.inspect} #{value.class}"
          puts "    v2:   nil NilClass"
        end
        result << false
      end
    end
    if result.count(false) > 0
      puts "#{result.count(false)} mismatches".red if verbose
    else
      puts "0 mismatches".green if verbose
    end
    return result.count(false) == 0
  end

  def self.normalize(model, key, value)
    # special case for month_year
    if key =~ /month_year/
      if value =~ /-/
        val = case value.split('-').length
        when 1
          Date.strptime(value, '%Y').end_of_year
        when 2
          Date.strptime(value, '%Y-%m').end_of_month
        when 3
          Date.strptime(value, '%Y-%m-%d')
        end
      else
        val = case value.split(' ').length
        when 1
          Date.strptime(value, '%Y').end_of_year
        when 2
          Date.strptime(value, '%B %Y').end_of_month
        when 3
          value.to_date
        end
      end
      return val.strftime('%Y-%m')
    end

    case value
    when String
      new_val = MAP.dig(model, key, value)
      new_val ? new_val.downcase.gsub(/ |_/,'') : value.downcase.gsub(/ |_/,'')
    when Integer
      value.to_s
    else
      value
    end
  end

  MAP = {
    study: {
      study_first_posted_date_type: {
        'Estimate' => 'ESTIMATED',
      },
      last_update_posted_date_type: {
        'Estimate' => 'ESTIMATED',
      },
      phase: {
        'Not Applicable' => 'NA',
      },
      completion_date_type: {
        'Anticipated' => 'ESTIMATED',  # NEED VERIFICATION
      },
      enrollment_type: {
        'Anticipated' => 'ESTIMATED', # NEED VERIFICATION
      }
    },
    ipd_information_type: {
      name: {
        'Informed Consent Form (ICF)' => 'ICF'
      }
    }
  }
end