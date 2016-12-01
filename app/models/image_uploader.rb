class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  storage :fog

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process :resize_to_limit => [200, 200]
  end

end
