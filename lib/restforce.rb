require 'faraday'
require 'faraday_middleware'
require 'json'

require 'hashie/mash'

require 'restforce/version'
require 'restforce/config'
require 'restforce/collection'
require 'restforce/sobject'
require 'restforce/client'

require 'restforce/middleware'

module Restforce
  class AuthenticationError < StandardError; end
  class InstanceURLError < StandardError; end
end
