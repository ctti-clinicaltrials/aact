class UseCase < AdminBase
  has_many :use_case_attachments
  attr_accessor :pwd
#  mount_uploader :image, ImageUploader

  def attachment
    use_case_attachments.first
  end

  def attachments
    use_case_attachments
  end

  def initialize(params = {})
    file = params.delete(:file)
    super
    self.attachments << UseCaseAttachment.create_from(file) if file
  end

end
