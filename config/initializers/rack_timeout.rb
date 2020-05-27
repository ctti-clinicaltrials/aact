# Rack::Timeout.service_timeout = 20  # seconds
# insert middleware wherever you want in the stack, optionally pass initialization arguments
Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 20

Rack::Timeout::StateChangeLoggingObserver::STATE_LOG_LEVEL[:ready] = :debug
Rack::Timeout::StateChangeLoggingObserver::STATE_LOG_LEVEL[:completed] = :debug
