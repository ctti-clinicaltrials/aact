# This sets up the base Grape endpoint mounts.
# We will use api versioning, with the version being part of the url scheme
# this is most easily accomplished by mounting version specific Base Grape
# endpoints into this Base module.
module AACT2
  class Base < Grape::API
    mount AACT2::V1::Base
  end
end
