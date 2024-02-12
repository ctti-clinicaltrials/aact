class StudyJsonRecord::Worker
  StudyRelationship.load_mappings

  attr_accessor :collections

  def initialize
    @collections = Hash.new{|h,k| h[k] = []}
  end

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

  def prepare_children(parent, entry, children)
    children.each do |mapping|
      collection = []
      child_root = entry.dig(*mapping[:root].map(&:to_s))
      next if child_root.nil?
      entries = child_root.is_a?(Array) ? child_root : [child_root]
      entries = entries.select{|e| mapping[:filter].call(e)} if mapping[:filter]
      entries.each_with_index do |entry, index|
        values = mapping[:columns].map do |column|
          [column[:name], get_value(column, entry, index)]
        end
        row = mapping[:table].to_s.classify.constantize.new(Hash[values])
        prepare_children(row, entry, mapping[:children]) if mapping[:children]
        collection << row
        collections[mapping[:table]] << row
      end
      parent.send("#{mapping[:table].to_s.pluralize}=", collection)
    end
  end

  def save_children(parents)
    return unless parents.first
    klass = parents.first.class
    return if klass == Study
    klass.reflect_on_all_associations(:has_many).each do |association|
      # update the nct_id and parent_id of the children
      collection = []
      collections[association.name].each do |child|
        if association.inverse_of.nil?
          byebug
        end
        parent = child.send(association.inverse_of.name)
        child.nct_id = parent.nct_id
        child[association.foreign_key] = parent.id
        collection << child
      end
      next if collection.empty?
      collection.first.class.import(collection)
      save_children(collection)
    end
  end


  def process(count=1)
    # load records
    records = StudyJsonRecord.where(version: '2').where('updated_at > saved_study_at OR saved_study_at IS NULL').limit(count)
    print "records: #{records.count}"

    # remove records data
    StudyRelationship.study_models.each do |model|
      model.where(nct_id: records.map(&:nct_id)).delete_all
    end

    @collections = Hash.new{|h,k| h[k] = []}

    # import records data
    StudyRelationship.mapping.each do |mapping| # process each mapping instructions
      model = mapping[:table].to_s.classify.constantize
      root = mapping[:root].map(&:to_s) if mapping[:root]
      collection = []

      # prepare models for importing
      records.each do |record|
        puts "processing #{record.nct_id} for #{model}"
        mapping_root = root ? record.content.dig(*root) : record.content
        # puts " mapping-root: #{mapping_root.inspect}"
        next if mapping_root.nil?
        entries = mapping_root.is_a?(Array) ? mapping_root : [mapping_root]
        entries = entries.select{|e| mapping[:filter].call(e)} if mapping[:filter]
        entries.each_with_index do |entry, index|
          values = mapping[:columns].map do |column|
            [column[:name], get_value(column, entry, index)]
          end
          row = model.new(Hash[values])
          row.nct_id = record.nct_id
          prepare_children(row, entry, mapping[:children]) if mapping[:children]
          collection << row
        end
      end
      # import models
      model.import(collection)
      save_children(collection)
    end
    byebug

    # mark records as saved
    StudyJsonRecord.where(version: '2').where(nct_id: records.map(&:nct_id)).update_all(saved_study_at: Time.now)
  end

  private

  # column - describes where to get the value & how to convert the value before saving
  # root - the json object to search for the value
  def get_value(column, root, index=nil)
    # get value from json
    case column[:value]
    when Array # deep level in hierarchy
      path = column[:value].map(&:to_s) 
      value = root.dig(*path)
    when Symbol # single level in hierarchy
      value = root.dig(column[:value].to_s)
    when NilClass # root level
      value = root
    when Proc # dynamic value
      value = column[:value].call(root, index)
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