class UseCase < ActiveRecord::Base
  has_many :use_case_attachments
  mount_uploader :image, ImageUploader

  def attachments
    use_case_attachments
  end

end
