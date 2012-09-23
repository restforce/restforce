require 'faraday'
require 'faraday_middleware'
require 'json'
require 'faye'

require 'openssl'
require 'base64'

require 'restforce/version'
require 'restforce/config'
require 'restforce/mash'
require 'restforce/collection'
require 'restforce/sobject'
require 'restforce/upload_io'
require 'restforce/client'

require 'restforce/middleware'

module Restforce
  class << self
    # Alias for Restforce::Client.new
    #
    # Shamelessly pulled from https://github.com/pengwynn/octokit/blob/master/lib/octokit.rb
    def new(options = {})
      Restforce::Client.new(options)
    end
  end

  class AuthenticationError < StandardError; end
  class UnauthorizedError < StandardError; end
end
