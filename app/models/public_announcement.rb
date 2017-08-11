class PublicAnnouncement < AdminBase

  def self.populate(string)
    self.destroy_all
    announcement=new(:description=>string)
    announcement.save!
    announcement
  end

end
