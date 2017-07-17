CarrierWave.configure do |config|
    config.cache_dir = "#{Rails.root}/tmp/uploads"
    config.fog_credentials = {
      :provider               => 'DigitalOcean',
      :region                 => 'NYC1',
      :digitalocean_token     => ENV['FOG_TOKEN'],
    }
    config.fog_directory  = '/var/local/share/images'
    config.fog_public     = false                                   # optional, defaults to true
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}

    # For testing, upload files to local `tmp` folder.
    if Rails.env.test?
      config.storage = :file
      config.enable_processing = false
      config.root = "#{Rails.root}/tmp"
    else
      config.storage = :fog
    end
end

module Carrierwave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img * yield(img) if block_given?
        img
      end
    end
  end
end
