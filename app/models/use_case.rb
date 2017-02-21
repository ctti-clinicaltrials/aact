class UseCase < AdminBase
  has_many :use_case_attachments, :dependent => :destroy
  mount_uploader :image, ImageUploader
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create

  def initialize(params = {})
    file = params.delete(:file)
    image_file = params.delete(:image_file)
    super
    self.attachments << UseCaseAttachment.create_from(file) if file
    self.image = image_file if image_file
    self
  end

  def update(params = {})
    image_file = params.delete('image_file')
    self.use_case_attachments = []
    self.attachments << UseCaseAttachment.create_from(file) if file
    self.image = image_file if image_file
    super
    self
  end

  def linkable_url
    return nil if self.url.blank?
    if self.url.match(/^http:\/\//) or self.url.match(/^https:\/\//)
      self.url
    else
      "http://#{self.url}"
    end
  end

  def attachment
    attachments.first
  end

  def attachments
    use_case_attachments
  end


end
