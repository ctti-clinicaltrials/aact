class StudyJsonRecord::Worker
  StudyRelationship.load_mappings

  def date(str)
    return unless str
    case str.split('-').length
    when 1
      Date.strptime(str, '%Y').end_of_year
    when 2
      Date.strptime(str, '%Y-%m').end_of_month
    when 3
      str =~ /T/ ? DateTime.strptime(str, '%Y-%m-%dT%H:%M') : Date.strptime(str, '%Y-%m-%d')
    end
  end

  def downcase(str)
    str.try(:downcase)
  end

  def self.reset
    StudyRelationship.study_models.each{|k| k.delete_all}
    StudyJsonRecord.where(version: '2').update_all(saved_study_at: nil)
  end

  def process(count=2)
    # load records
    records = StudyJsonRecord.where(version: '2').where('updated_at > saved_study_at OR saved_study_at IS NULL').limit(count)

    # remove records data
    StudyRelationship.study_models.each do |model|
      model.where(nct_id: records.map(&:nct_id)).delete_all
    end

    # import records data
    StudyRelationship.mapping.each do |mapping| # process each mapping instructions
      model = mapping[:table].to_s.classify.constantize
      root = mapping[:root].map(&:to_s) if mapping[:root]
      collection = []

      # prepare models for importing
      records.each do |record|
        mapping_root = root ? record.content.dig(*root) : record.content
        next if mapping_root.nil?
        entries = mapping_root.is_a?(Array) ? mapping_root : [mapping_root]
        entries.each do |entry|
          values = mapping[:columns].map do |column|
            [column[:name], get_value(column, entry)]
          end
          row = model.new(Hash[values])
          row.nct_id = record.nct_id
          collection << row
        end
      end

      # import models
      model.import(collection)
    end

    # mark records as saved
    StudyJsonRecord.where(version: '2').where(nct_id: records.map(&:nct_id)).update_all(saved_study_at: Time.now)
  end

  private

  # column - describes where to get the value & how to convert the value before saving
  # root - the json object to search for the value
  def get_value(column, root)
    # get value from json
    case column[:value]
    when Array # deep level in hierarchy
      path = column[:value].map(&:to_s) 
      value = root.dig(*path)
    when Symbol # single level in hierarchy
      value = root.dig(column[:value].to_s)
    when NilClass # root level
      value = root
    else # static value
      value = column[:value]
    end

    # convert value if needed
    case column[:convert_to]
    when Symbol
      send(column[:convert_to], value)
    when Proc
      column[:convert_to].call(value)
    else
      value
    end
  rescue
    puts "Error getting #{column[:value]} from #{root}"
    raise $!
  end
end