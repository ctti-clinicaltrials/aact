# frozen_string_literal: true

# This module is reponsible for applying all the mappings to any StudyJsonRecord objects that need to be updated
module StudyJsonRecord::Worker # rubocop:disable Style/ClassAndModuleChildren
  StudyRelationship.load_mappings

  attr_accessor :collections

  def initialize
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

  def downcase(str)
    str.try(:downcase)
  end

  def self.reset
    StudyRelationship.study_models.each(&:delete_all)
    StudyJsonRecord.where(version: '2').update_all(saved_study_at: nil) # rubocop:disable Rails/SkipsModelValidations
  end

  def save_children(parents)
    return unless parents.first

    klass = parents.first.class
    return if klass == Study

    klass.reflect_on_all_associations(:has_many).each do |association|
      # update the nct_id and parent_id of the children
      collection = []
      collections[association.name].each do |child|
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

  def process(count = 1)
    # load records
    records = StudyJsonRecord.where(version: '2').where('updated_at > saved_study_at OR saved_study_at IS NULL').limit(count)
    Rails.logger.debug { "records: #{records.count}" }

    remove_study_data(records.map(&:nct_id))

    @collections = Hash.new { |h, k| h[k] = [] }

    # import records data
    StudyRelationship.mapping.each do |mapping| # process each mapping instructions
      process_mapping(mapping, records)
    end

    # mark study records as saved
    StudyJsonRecord.where(version: '2').where(nct_id: records.map(&:nct_id)).update_all(saved_study_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def prepare_children(parent, content, children)
    children.each do |mapping|
      nct_id = parent.nct_id

      collection = [] # this array will collect all the models to be imported
      model = mapping[:table].to_s.classify.constantize # get the model from the table name
      root = mapping[:root].map(&:to_s) if mapping[:root] # normalize root path to array of strings

      mapping_root = root ? content.dig(*root) : content
      next if mapping_root.nil? # skip if no root found

      entries = mapping_root.is_a?(Array) ? mapping_root : [mapping_root]

      entries = entries.select { |e| mapping[:filter].call(e) } if mapping[:filter]

      entries.each_with_index do |entry, index|
        values = mapping[:columns].map do |column|
          [column[:name], get_value(column, entry, index)]
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

  def process_mapping(mapping, records)
    model = mapping[:table].to_s.classify.constantize # get the model from the table name
    root = mapping[:root].map(&:to_s) if mapping[:root] # normalize root path to array of strings
    collection = [] # this array will collect all the models to be imported

    # prepare models for importing
    records.each do |record|
      nct_id = record.nct_id
      content = record.content
      # get the root json, this allows us to focus on a smaller json object
      mapping_root = root ? content.dig(*root) : content
      next if mapping_root.nil? # skip if no root found

      # normalize entries to array, even if there is only one entry we want to treat it as an array
      entries = mapping_root.is_a?(Array) ? mapping_root : [mapping_root]

      # filter entries
      entries = entries.select { |e| mapping[:filter].call(e) } if mapping[:filter]

      # performing the mapping on the json objects
      entries.each_with_index do |entry, index|
        values = mapping[:columns].map do |column|
          [column[:name], get_value(column, entry, index)]
        end
        row = model.new(values.to_h)
        row.nct_id = nct_id
        prepare_children(row, entry, mapping[:children]) if mapping[:children]
        collection << row
        collections[mapping[:table]] << row
      end
    end

    # import models
    model.import(collection)
    save_children(collection)
  end

  # remove all the aact data for the given nct_ids
  def remove_study_data(nct_ids)
    StudyRelationship.study_models.each do |model|
      model.where(nct_id: nct_ids).delete_all
    end
  end

  # call a converter method or proc to convert the value
  def convert_value(column, value)
    case column[:convert_to]
    when Symbol
      send(column[:convert_to], value)
    when Proc
      column[:convert_to].call(value)
    else
      value
    end
  end

  # column - describes where to get the value & how to convert the value before saving
  # root - the json object to search for the value
  def get_value(column, root, index = nil)
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
      value = column[:value].call(root, index)
    else # static value
      value = column[:value]
    end

    convert_value(column, value)
  rescue StandardError
    Rails.logger.debug { "Error getting #{column[:value]} from #{root}" }
    raise $ERROR_INFO
  end
end
