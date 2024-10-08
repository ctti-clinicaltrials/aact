# frozen_string_literal: true

# This module is reponsible for applying all the mappings to any StudyJsonRecord objects that need to be updated
class StudyJsonRecord::Worker # rubocop:disable Style/ClassAndModuleChildren
  StudyRelationship.load_mappings

  attr_accessor :collections

  def initialize
    puts "New Worker initialized".red unless Rails.env.test?
    @collections = Hash.new { |h, k| h[k] = [] }
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

  def date_first_of_month(str)
    return unless str

    case str.split('-').length
    when 1
      Date.strptime(str, '%Y').end_of_year
    when 2
      Date.strptime(str, '%Y-%m').beginning_of_month
    when 3
      str =~ /T/ ? DateTime.strptime(str, '%Y-%m-%dT%H:%M') : Date.strptime(str, '%Y-%m-%d')
    end
  end

  def downcase(str)
    str.try(:downcase)
  end

  def float(str)
    Float(str) rescue nil
  end

  def save_children(parents, indent="  ")
    return unless parents.first

    klass = parents.first.class
    return if klass == Study


    klass.reflect_on_all_associations(:has_many).each do |association|
      # update the nct_id and parent_id of the children
      collection = []
      collections[association.name].each do |child|
        inverse_name = association.inverse_of&.name
        next unless inverse_name
  
        parent = child.send(inverse_name)
        # keeping this temprorary fix until we find a better solution
        if parent.nil?
          puts "Skipping child because parent is nil"
          puts "Parrent: #{inverse_name}, child: #{association.name}"
          next
        end
        child.nct_id = parent.nct_id
        child[association.foreign_key] = parent.id
        collection << child
      end
      next if collection.empty?

      print "#{indent}   ↳ #{collection.first.class.table_name} - #{collection.count}" unless Rails.env.test?
      collection.first.class.import(collection)
      puts "\r✅#{indent} ↳ #{collection.first.class.table_name} - #{collection.count}" unless Rails.env.test?
      save_children(collection,"  #{indent}")
    end
  end

  def import_all(batch_size=1000)
    silence_active_record do
      records = StudyJsonRecord.version_2.needs_processing.count
      puts "worker has #{records} updated records to process".green
      while records > 0
        process(batch_size)
        records = StudyJsonRecord.version_2.needs_processing.count
      end
    end
  end

  def process_study(nct_id)
    process(1, StudyJsonRecord.where(nct_id: nct_id, version: '2'))
  end

  def process(count = 1, records = nil)
    # load records
    records = StudyJsonRecord.version_2.needs_processing.limit(count) if records.nil?
    return if records.empty?
    nct_ids = records.map(&:nct_id)
    Rails.logger.debug { "records: #{nct_ids.count}" }

    puts "worker is about to process #{nct_ids.count} records".green  unless Rails.env.test?
    remove_study_data(nct_ids)

    @collections = Hash.new { |h, k| h[k] = [] }
    @index = Hash.new { |h, k| h[k] = {} }

    # import records data
    StudyRelationship.sorted_mapping.each do |mapping| # process each mapping instructions
      process_mapping(mapping, records)
    end
    
    ResultGroup.handle_outcome_result_groups_ids(nct_ids)
    CalculatedValue.populate_for(nct_ids)
    # mark study records as saved
    StudyJsonRecord.version_2.where(nct_id: nct_ids).update_all(saved_study_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
  end

  # private

  def prepare_children(parent, content, children)
    children.each do |mapping|
      nct_id = parent.nct_id

      collection = [] # this array will collect all the models to be imported
      model = mapping[:table].to_s.classify.constantize # get the model from the table name
      root = mapping[:root].map(&:to_s) if mapping[:root] # normalize root path to array of strings
      mapping_root = root ? content.dig(*root) : content
      next if mapping_root.nil? # skip if no root found

      entries = mapping_root.is_a?(Array) ? mapping_root : [mapping_root]

      # flatten the entries if needed
      entries = flatten(mapping[:flatten].clone, entries) if mapping[:flatten]

      entries = entries.select { |e| mapping[:filter].call(e) } if mapping[:filter]

      entries.each_with_index do |entry, index|
        values = mapping[:columns].map do |column|
          [column[:name], get_value(column, entry, index, nct_id)]
        end
        row = model.new(values.to_h)
        row.nct_id = nct_id
        prepare_children(row, entry, mapping[:children]) if mapping[:children]
        collection << row
        collections[mapping[:table]] << row
      end

      parent.send("#{mapping[:table].to_s.pluralize}=", collection)
    end
  end

  def build
    root = content.dig('resultsSection', 'participantFlowModule', 'periods')
    flatten = ['milestones', 'achievements']
    flatten(flatten, root)
  end

  def append_parent(hash, value)
    return unless hash
    if hash['$parent']
      append_parent(hash['$parent'], value)
    else
      hash['$parent'] = value
    end
  end

  def add_missing_keys(item, keys)
    return item if keys.empty?

    key = keys.first
    remaining_keys = keys.drop(1)

    unless item.key?(key.to_s)
      item[key.to_s] = remaining_keys.empty? ? [{}] : [add_missing_keys({}, remaining_keys)]
      # puts "🛑 data after adding new key to item: #{item}"
    end

    item
  end

  def flatten(path, data, parent=nil)
    # puts "🛑🛑🛑🛑 FLATTEN #{path} - #{data} - #{parent} 🛑🛑🛑🛑"
    return [] unless data
    child_key = path.first
    result = []
    if !child_key.nil? && !data.first.key?(child_key.to_s) && path == [:categories, :measurements]
      # puts "🛑 #{path} found in path but not in data}"
      data.each do |item|
        add_missing_keys(item, path)
      end
    end


    if child_key.nil?
      data.each { |i| append_parent(i, parent) } if parent
      return data
    else
    result = data.map do |item|
      children = item.delete(child_key.to_s)
      if children.nil? || children.empty?
        nil
      else
        res = flatten(path[1..-1], children, item)
        # if res.first.nil?
        #   byebug
        # end
        append_parent(res.first, parent) if parent
        res
      end
    end
      return result.compact.flatten
    end
  end
  
  def process_mapping(mapping, records)
    print "   #{mapping[:table]}" unless ENV['RAILS_ENV'] == 'test'
    model = mapping[:table].to_s.classify.constantize # get the model from the table name
    root = mapping[:root].map(&:to_s) if mapping[:root] # normalize root path to array of strings
    collection = [] # this array will collect all the models to be imported

    # prepare models for importing
    records.each do |record|
      nct_id = record.nct_id
      @current_nct_id = nct_id
      content = record.content
      # get the root json, this allows us to focus on a smaller json object
      mapping_root = root ? content.dig(*root) : content
      next if mapping_root.nil? # skip if no root found

      # normalize entries to array, even if there is only one entry we want to treat it as an array
      entries = mapping_root.is_a?(Array) ? mapping_root : [mapping_root]

      # flatten the entries if needed
      entries = flatten(mapping[:flatten].clone, entries) if mapping[:flatten]

      # filter entries
      entries = entries.select { |e| mapping[:filter].call(e) } if mapping[:filter]

      # performing the mapping on the json objects
      entries.each_with_index do |entry, index|
        values = mapping[:columns].map do |column|
          [column[:name], get_value(column, entry, index, nct_id)]
        end
        row = model.new(values.to_h)
        row.nct_id = nct_id
        prepare_children(row, entry, mapping[:children]) if mapping[:children]
        collection << row
        collections[mapping[:table]] << row
      end
    end

    # remove duplicates
    if mapping[:unique]
      collection = collection.uniq{|k| k.attributes }
    end

    # import models
    print "\r   #{mapping[:table]} - #{collection.count}" unless ENV['RAILS_ENV'] == 'test'
    model.import(collection)
    puts "\r✅ #{mapping[:table]} - #{collection.count}" unless ENV['RAILS_ENV'] == 'test'
    
    if mapping[:index]
      index = [:nct_id] + mapping[:index]
      collection.each do |row|
        row_index = index.map { |i| row.send(i) }
        @index[mapping[:table]][row_index] = row.id
      end
    end

    save_children(collection)
  rescue
    raise "Error processing #{mapping[:table]}"
  end

  # remove all the aact data for the given nct_ids
  def remove_study_data(nct_ids)
    StudyRelationship.study_models.each do |model|
      model.where(nct_id: nct_ids).delete_all
    end
  end

  # call a converter method or proc to convert the value
  def convert_value(column, value, nct_id = nil)
    case column[:convert_to]
    when Symbol
      send(column[:convert_to], value)
    when Proc
      column[:convert_to].arity == 1 ? column[:convert_to].call(value) : column[:convert_to].call(value, nct_id)
    else
      value
    end
  end

  # column - describes where to get the value & how to convert the value before saving
  # root - the json object to search for the value
  def get_value(column, root, index = nil, nct_id = nil)
    # get value from json
    case column[:value]
    when Array # deep level in hierarchy
      path = column[:value].map(&:to_s)
      value = root.dig(*path)
    when Symbol # single level in hierarchy
      value = root[column[:value].to_s]
    when NilClass # root level
      value = root
    when Proc # dynamic value
      value = column[:value].arity == 1 ? column[:value].call(root) : column[:value].call(root, index)
    when StudyRelationship::Reference # reference to another model
      index = column[:value].index.map { |i| get_value({value: i}, root) }
      value = @index[column[:value].table][[@current_nct_id] + index]
    else # static value
      value = column[:value]
    end

    convert_value(column, value, nct_id)
  rescue StandardError
    Rails.logger.debug { "Error getting #{column[:value]} from #{root}" }
    raise $ERROR_INFO
  end
end
