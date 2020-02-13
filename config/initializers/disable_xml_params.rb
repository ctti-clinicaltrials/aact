# ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
ActionDispatch::Request.parameter_parsers = ActionDispatch::Request.parameter_parsers.except(:json)
