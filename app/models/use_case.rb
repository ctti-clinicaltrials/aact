class UseCase < ActiveRecord::Base
  has_many :use_case_attachments
  mount_uploader :image, ImageUploader

  def attachments
    use_case_attachments
  end

  def image_changed?
    # TODO - this is just to debug carrierwave error on heroku.  remove this method
    false
  end
end
