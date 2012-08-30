require 'faraday'
require 'faraday_middleware'

require 'hashie/mash'

require 'restforce/version'
require 'restforce/config'
require 'restforce/client'

require 'restforce/middleware/authentication'
require 'restforce/middleware/password_authentication'
require 'restforce/middleware/oauth_refresh_authentication'
require 'restforce/middleware/authorization'
require 'restforce/middleware/instance_url'

module Restforce
  class AuthenticationError < StandardError; end
  class InstanceURLError < StandardError; end
end
