ActionDispatch::Request.parameter_parsers.delete(Mime[:xml])
# ActionDispatch::Request.parameter_parsers = ActionDispatch::Request.parameter_parsers.except(:json)
