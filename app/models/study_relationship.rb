require 'csv'
require 'active_support/all'

class StudyRelationship < ActiveRecord::Base
  self.abstract_class = true;
  attr_accessor :xml, :opts, :wrapper1_xml
  belongs_to :study, :foreign_key=> 'nct_id'

  def self.create_all_from(opts)
    original_xml=opts[:xml]
    original_outer_xml=opts[:outer_xml]
    objects=xml_entries(opts).collect{|xml|
      opts[:xml]=xml
      new.create_from(opts)
    }.compact
    opts[:xml]=original_xml
    opts[:outer_xml]=original_outer_xml
    return objects
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

  def self.xml_entries(opts)
    opts[:xml].xpath(top_level_label)
  end

  def self.remove_existing(nct_id)
    existing=self.where(nct_id: nct_id)
    existing.each{|x|x.destroy!}
  end

  def wrapper1_xml
    @wrapper1_xml ||= Nokogiri::XML('')
  end

  def conditionally_create_from(opts)
    # this is a hook that any model can override to decide whether or not to proceed
    create_from(opts)
  end

  def create_from(opts={})
    @opts=opts
    @xml=opts[:xml]
    self.nct_id=opts[:nct_id]
    assign_attributes(attribs) if !attribs.blank?
    self
  end

  def get_from_wrapper1(label)
    wrapper1_xml.xpath("#{label}").inner_html
  end

  def get(label)
    xml.xpath("#{label}").inner_html
  end

  def get_text(label)
    str=''
    nodes=xml.xpath("//#{label}")
    nodes.each {|node| str << node.xpath("textblock").inner_html}
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
    val=xml.xpath("//#{label}").try(:inner_html)
    val.downcase=='yes'||val.downcase=='y'||val.downcase=='true' if !val.blank?
  end

end
