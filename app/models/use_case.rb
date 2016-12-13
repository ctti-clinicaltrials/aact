class UseCase < ActiveRecord::Base
  has_many :use_case_attachments
  attr_accessor :pwd
  mount_uploader :image, ImageUploader

  def attachments
    use_case_attachments
  end

end
