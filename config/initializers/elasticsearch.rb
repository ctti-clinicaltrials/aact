Rails.application.config.action_dispatch.cookies_serializer = :json
config = {
  host: "http://search-clinicaltrials-em5oakgu5hjoo4j4gvqqpprscq.us-east-1.es.amazonaws.com/",
  url: ENV["QUOTAGUARDSTATIC_URL"]
  #host: "https://debd374a8aad3b5bbad9639d3dcdedf6.us-east-1.aws.found.io:9243"
}

if File.exists?("config/elasticsearch.yml")
  config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].symbolize_keys)
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)
