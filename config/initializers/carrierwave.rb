unless ENV['AWS_ACCESS_KEY_ID'].blank?
  CarrierWave.configure do |config|
#    config.root = Rails.root.join('tmp')
#    config.cache_dir = 'carrierwave'
    # Need next line to work on heroku
    config.cache_dir = "#{Rails.root}/tmp/uploads"
    config.fog_credentials = {
      :provider               => 'AWS',
      :region                 => ENV['AWS_REGION'],
      :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY']
    }
    config.fog_directory  = ENV['S3_BUCKET_NAME']
    config.fog_public     = false                                   # optional, defaults to true
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
    config.fog_host         = "#{ENV['FILESERVER_ENDPOINT']}/#{ENV['S3_BUCKET_NAME']}"
  end
end

  # For testing, upload files to local `tmp` folder.
  if Rails.env.test?
    config.storage = :file
    config.enable_processing = false
    config.root = "#{Rails.root}/tmp"
  else
    config.storage = :fog
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
