Rails.application.config.action_dispatch.cookies_serializer = :json
config = {
  host: ENV['ELASTICSEARCH_URL'],
  credentials: Aws::Credentials.new(ENV['AWS_ELASTICSEARCH_KEY'], ENV['AWS_ELASTICSEARCH_SECRET']),
  url: ENV['QUOTAGUARDSTATIC_URL']
}

if File.exists?("config/elasticsearch.yml")
  config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].symbolize_keys)
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
