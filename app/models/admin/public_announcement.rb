class Admin::PublicAnnouncement < Admin::AdminBase

  def self.populate(string)
    clear_load_message
    new(:description=>string).save!
  end

  def self.populate_long_term(string)
    new(:description=>string,:is_sticky=>true).save!
  end

  def self.clear_load_message
    where('is_sticky is not true').each{|pa|pa.destroy}
  end
end
