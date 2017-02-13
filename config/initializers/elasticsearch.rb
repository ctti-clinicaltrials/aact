require 'faraday_middleware/aws_signers_v4'
Rails.application.config.action_dispatch.cookies_serializer = :json

credentials=Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
Elasticsearch::Model.client = Elasticsearch::Client.new(host: ENV['ELASTICSEARCH_URL']) do |f|
  f.request :aws_signers_v4,
    credentials: credentials,
    service_name: 'es',
    host:  ENV['ELASTICSEARCH_URL'],
    region: ENV['AWS_REGION']
  f.response :logger
  f.adapter  Faraday.default_adapter
end
