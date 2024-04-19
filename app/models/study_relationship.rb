require 'active_support/all'

class StudyRelationship < ActiveRecord::Base
  class Reference
    attr_accessor :table, :index

    def initialize(table)
      @table = table
    end

    def [](*args)
      @index = args
      self
    end
  end

  self.abstract_class = true;
  attr_accessor :xml, :opts
  belongs_to :study, :foreign_key=> 'nct_id'

  def self.blacklist
    %w(
      ar_internal_metadata
      schema_migrations
      data_definitions
      mesh_headings
      mesh_terms
      load_events
      sanity_checks
      study_searches
      statistics
      study_xml_records
      study_json_records
      use_cases
      study_records
      use_case_attachments
      verifiers
      load_issues
      study_records
      active_storage_variant_records
      active_storage_blobs
      active_storage_attachments
      file_records
      study_statistics_comparisons
      background_jobs
    )
  end

  def self.loadable_tables
    connection.tables - blacklist
  end

  def self.study_models
    return @models if @models
    @models = (connection.tables - blacklist).map{|k| k.singularize.camelize.constantize }
  end

  def self.remove_all_data
    study_models.each do |model|
      model.delete_all
    end
  end

  def self.create_nct_indexes
    blacklist = %w(
      ar_internal_metadata
      schema_migrations
      data_definitions
      mesh_headings
      mesh_terms
      load_events
      sanity_checks
      study_searches
      statistics
      study_xml_records
      study_json_records
      use_cases
      use_case_attachments
      verifiers
    )
    tables = connection.tables - blacklist
    tables.each do |table|
      begin
        connection.execute("CREATE INDEX #{table}_nct_idx ON #{table}(nct_id)")
      rescue => e
        puts "#{e.message}"
        puts "DONT CREATE #{table}"
      end
    end
  end

  def self.create_all_from(opts)
    objects=xml_entries(opts).collect{|xml|
      opts[:xml]=xml
      new.create_from(opts)
    }.compact
    objects
  end

  def self.create_from(opts)
    new.conditionally_create_from(opts)
  end

  def self.pop_create(opts)
    name=opts[:name]
    list=opts[:xml].xpath("#{name}_list") if opts[:xml]
    all=(list ? list.xpath(name) : [])
    col=[]
    xml=all.pop
    while xml
      opts[:xml]=xml
      col << create_from(opts)
      xml=all.pop
    end
    col
  end

  def self.top_level_label
    puts '#top_level_label: subclass responsibility!'
  end

  def self.create_group_set(opts)
    ResultGroup.create_group_set(opts)
  end

  def get_group(groups)
    groups.select{|g|g.ctgov_group_code==gid}.first
  end

  def gid
    get_attribute('group_id')
  end

  def self.xml_entries(opts)
    opts[:xml].xpath(top_level_label)
  end

  def self.remove_existing(nct_id)
    existing=self.where(nct_id: nct_id)
    existing.each{|x|x.destroy!}
  end

  def conditionally_create_from(opts)
    # this is a hook that any model can override to decide whether or not to proceed
    create_from(opts)
  end

  def create_from(opts={})
    @opts = opts
    @xml = opts[:xml] || opts
    self.nct_id=opts[:nct_id]
    a=attribs
    a = fix_na_values(a)
    if a.nil?
      return nil
    else
      assign_attributes(a)
    end
    self
  end

  def fix_na_values(attributes)
    self.class.columns_hash.keys.each do |key|
      if [:integer, :numeric, :double, :decimal].include?(self.class.columns_hash[key].type) && attributes.present?
        attributes[:"#{key}"] = "" if attributes[:"#{key}"] == 'NA'
      end
    end
    return attributes
  end

  def get(label)
    value=(xml.xpath("#{label}").text).strip
    value=='' ? nil : value
  end

  def get_text(label)
    str=''
    nodes=xml.xpath("//#{label}")
    nodes.each {|node| str << node.xpath("textblock").text}
    str
  end

  def get_child(label)
    xml.children.collect{|child| child.text if child.name==label}.compact.first
  end

  def get_attribute(label)
    xml.attribute(label).try(:value) if !xml.blank?
  end

  def integer_in(str)
    str.scan(/[0-9]/).join.to_i if !str.blank?
  end

  def self.integer_in(str)
    str.scan(/[0-9]/).join.to_i if !str.blank?
  end

  def self.trim(str)
    str.tr("\n\t ", "")
  end

  def get_opt(label)
    @opts[label.to_sym]
  end

  def get_type(label)
    node=xml.xpath("//#{label}")
    node.attribute('type').try(:value) if !node.blank?
  end

  def get_boolean(label)
    val=xml.xpath("//#{label}").try(:text)
    return nil if val.blank?
    return true  if val.downcase=='yes' || val.downcase=='y' || val.downcase=='true'
    return false if val.downcase=='no' || val.downcase=='n' || val.downcase=='false'
  end

  def get_phone
    ext = get('phone_ext')
    return "#{get('phone')} ext #{ext}" if !ext.blank?
    get('phone')
  end

  MAPPING = []

  def self.add_mapping
    entry = yield
    case entry
    when Array
      MAPPING.concat(entry)
    when Hash
      MAPPING << entry
    end
  end

  def self.whitelist
    []
  end

  def self.mapping
    if whitelist.empty?
      MAPPING
    else
      MAPPING.select{|m| whitelist.include?(m[:table]) }
    end
  end

  # perform topological sort on the mappings
  def self.sorted_mapping
    # 1. calculate the in-degrees of all nodes
    in_degrees = {}
    mapping.each do |m|
      next unless m[:requires]
      dependency = m[:requires].is_a?(Array) ? m[:requires] : [m[:requires]]
      dependency.each do |d|
        in_degrees[d] ||= 0
        in_degrees[d] += 1
      end
    end

    # 2. initialize the queue with nodes that have no dependencies
    queue = mapping.select{|m| in_degrees[m[:table]].nil? }

    # 3. perform the topological sort
    sorted = []
    while queue.any?
      node = queue.shift
      sorted << node
      next if node[:requires].nil?
      dependency = node[:requires].is_a?(Array) ? node[:requires] : [node[:requires]]
      mapping.select{|m| dependency.include?(m[:table]) }.each do |m|
        in_degrees[m[:table]] -= 1
        queue << m if in_degrees[m[:table]] == 0
      end
    end

    if sorted.length != mapping.length
      raise "Cycle detected in the mappings"
    end

    sorted.reverse
  end

  def self.reference(table)
    StudyRelationship::Reference.new(table)
  end

  def self.load_mappings
    study_models.each do |model|
      model.class
    end
    required_mappings = study_models.map{|k| k.name.underscore.to_sym }
    missing = required_mappings - MAPPING.map{|m| m[:table]}
    missing.each do |m|
      # puts "🛑 Missing mapping for #{m}"
    end
  end

  # removes relative references to $parent and generates the absolute path
  def self.collapse_path(path)
    i = 0
    while i < path.length
      if path[i] == :$parent
        path.delete_at(i)
        path.delete_at(i-1)
        i -= 1
      else
        i += 1
      end
    end
    return path
  end

  def self.update_data_definitions
    data_definitions = Hash.new{|h,k| h[k] = {} }
    
    MAPPING.each do |mapping|
      # normalize the root path
      root_path = []
      if mapping[:root].is_a?(Symbol)
        root_path << mapping[:root]
      elsif mapping[:root].is_a?(Array)
        root_path += mapping[:root]
      end

      # add the flatten parth
      if mapping[:flatten]
        root_path += mapping[:flatten]
      end

      mapping[:columns].each do |column|
        column_path = nil
        case column[:value]
        when Symbol
          column_path = [column[:value]]
        when Array
          column_path = column[:value]
        when nil
          column_path = []
        end
        source = column_path ? collapse_path(root_path + column_path) : nil
        
        if data_definitions[mapping[:table]][column[:name]]
          s = data_definitions[mapping[:table]][column[:name]][:source]
          data_definitions[mapping[:table]][column[:name]][:source] = s + " or " + source&.join(".") if source
        else
          data_definitions[mapping[:table]][column[:name]] = { 
            table_name: mapping[:table], 
            column_name: column[:name], 
            data_type: mapping[:table].to_s.classify.constantize.type_for_attribute(column[:name]).type,
            db_section: (root_path.first || 'protocol').to_s.gsub(/Section/,''),
            source: source&.join(".")
          }
        end
      end
    end

    data_definitions.each do |table_name, columns|
      columns.each do |column_name, data|
        definition = Admin::DataDefinition.find_by(table_name: table_name, column_name: column_name)
        if definition
          definition.update(data)
        else
          Admin::DataDefinition.create(data)
        end
      end
    end
  end
end
