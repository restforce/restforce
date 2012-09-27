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

    # Public: Decodes a signed request received from Force.com Canvas.
    #
    # message       - The POST message containing the signed request from Salesforce.
    # client_secret - The oauth client secret used to encrypt the message.
    #
    # Returns the Hash context if the message is valid.
    def decode_signed_request(message, client_secret)
      encryped_secret, payload = message.split('.')
      digest = OpenSSL::Digest::Digest.new('sha256')
      signature = Base64.encode64(OpenSSL::HMAC.hexdigest(digest, client_secret, payload))
      JSON.parse(Base64.decode64(payload)) if encryped_secret == signature
    end
  end

  class AuthenticationError < StandardError; end
  class UnauthorizedError < StandardError; end
end
