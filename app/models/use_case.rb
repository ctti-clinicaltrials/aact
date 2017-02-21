class UseCase < AdminBase
  has_many :use_case_attachments, :dependent => :destroy
  mount_uploader :image, ImageUploader
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create

  def attachment
    attachments.first
  end

  def attachments
    use_case_attachments
  end

  def initialize(params = {})
    file = params.delete(:file)
    image_file = params.delete(:image_file)
    super
    self.attachments << UseCaseAttachment.create_from(file) if file
    self.image = image_file if image_file
    self
  end

end
