CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp')
  config.cache_dir = 'carrierwave'
  config.fog_credentials = {
    :provider               => 'AWS',
    :s3_access_key_id      => ENV['S3_ACCESS_KEY'],                        # required
    :s3_secret_access_key  => ENV['S3_SECRET_KEY'],                     # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY']
  }
  config.fog_directory  = ENV['S3_BUCKET_NAME']
  config.fog_public     = false                                   # optional, defaults to true
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end

