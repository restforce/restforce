require 'faraday'
require 'faraday_middleware'

require 'hashie/mash'

require 'restforce/version'
require 'restforce/config'
require 'restforce/client'

require 'restforce/middleware'

module Restforce
  class AuthenticationError < StandardError; end
  class InstanceURLError < StandardError; end
end
