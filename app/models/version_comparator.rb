class VersionComparator
  def self.check(nct_id, matcher)
    ActiveRecord::Base.logger.level = Logger::ERROR

    StudyDownloader.download([nct_id], '1')
    StudyDownloader.download([nct_id], '2')

    # version 1
    record = StudyJsonRecord.find_by(nct_id: nct_id, version: "1")
    record = StudyDownloader.download([nct_id], '1') unless record
    record.preprocess
    v1 = record.send(matcher)

    # version 2
    record = StudyJsonRecord.find_by(nct_id: nct_id, version: "2")
    record = StudyDownloader.download([nct_id], '2') unless record
    processor = StudyJsonRecord::ProcessorV2.new(record.content)
    v2 = processor.send(matcher)

    compare(v1, v2)
  end

  private

  def self.compare(v1, v2)
    return unless v1
    v1.each do |key, value|
      if v2.key?(key)
        if normalize(key, v2[key]) != normalize(key, value)
          puts "#{key}"
          puts "  v1: #{value.inspect} #{value.class}"
          puts "  v2: #{v2[key].inspect} #{v2[key].class}"
        end
      else
        puts "#{key}"
        puts "  v1: #{value.inspect} #{value.class}"
        puts "  v2:   nil NilClass"
      end
    end
    return nil
  end

  def self.normalize(key, value)
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
      value.downcase.gsub(/ /,'')
    when Integer
      value.to_s
    else
      value
    end
  end
end