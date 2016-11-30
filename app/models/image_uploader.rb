class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick
  storage :file

  def store_dir
    "public/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process :resize_to_limit => [200, 200]
  end

end
