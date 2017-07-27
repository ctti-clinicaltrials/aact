class PublicAnnouncement < AdminBase

  def self.populate(string)
    self.destroy_all
    new(:description=>string).save!
  end

end
