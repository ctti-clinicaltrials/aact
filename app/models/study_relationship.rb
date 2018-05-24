require 'active_support/all'

class StudyRelationship < ActiveRecord::Base
  self.abstract_class = true;
  attr_accessor :xml, :opts
  belongs_to :study, :foreign_key=> 'nct_id'

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
    if a.nil?
      return nil
    else
      assign_attributes(a)
    end
    self
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

end
