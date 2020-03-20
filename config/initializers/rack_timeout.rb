# Rack::Timeout.service_timeout = 20  # seconds
Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 20 # seconds
Rack::Timeout::StateChangeLoggingObserver::STATE_LOG_LEVEL[:ready] = :debug
Rack::Timeout::StateChangeLoggingObserver::STATE_LOG_LEVEL[:completed] = :debug
