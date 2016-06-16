Apipie.configure do |config|
  config.app_name                = "AACT 2 API"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/docs"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
end
