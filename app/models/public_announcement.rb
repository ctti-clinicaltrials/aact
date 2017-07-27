class PublicAnnouncement < AdminBase

  def self.populate(string)
    self.destroy_all
    pa=new(:description=>string).save!
    pa.save!
  end

end
