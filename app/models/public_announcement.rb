class PublicAnnouncement < AdminBase

  def self.populate(string)
    new(:description=>string).save!
  end

end
