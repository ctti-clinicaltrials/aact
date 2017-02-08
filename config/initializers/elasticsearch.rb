Rails.application.config.action_dispatch.cookies_serializer = :json
config = {
  host: ENV['ELASTICSEARCH_URL'],
  url: ENV['PROXIMO_URL']
}

#if File.exists?("config/elasticsearch.yml")
#  config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].symbolize_keys)
#end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
