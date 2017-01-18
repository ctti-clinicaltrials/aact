Rails.application.config.action_dispatch.cookies_serializer = :json
config = {
  host: "http://search-clinical-trials-ko346vpptimyxxulqjdiuqnl6i.us-east-1.es.amazonaws.com/"
}

if File.exists?("config/elasticsearch.yml")
  config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].symbolize_keys)
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
