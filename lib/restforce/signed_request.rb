# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'json'

module Restforce
  class SignedRequest
    # Public: Initializes and decodes the signed request
    #
    # signed_request - The POST message containing the signed request from Salesforce.
    # client_secret  - The oauth client secret used to encrypt the signed request.
    #
    # Returns the parsed JSON context.
    def self.decode(signed_request, client_secret)
      new(signed_request, client_secret).decode
    end

    def initialize(signed_request, client_secret)
      @client_secret = client_secret
      split_components(signed_request)
    end

    # Public: Decode the signed request.
    #
    # Returns the parsed JSON context.
    # Returns nil if the signed request is invalid.
    def decode
      return nil if signature != hmac

      JSON.parse(Base64.decode64(payload))
    end

    private

    attr_reader :client_secret, :signature, :payload

    def split_components(signed_request)
      @signature, @payload = signed_request.split('.')
      @signature = Base64.decode64(@signature)
    end

    def hmac
      OpenSSL::HMAC.digest(digest, client_secret, payload)
    end

    def digest
      digest_class.new('sha256')
    end

    def digest_class
      if RUBY_VERSION < '2.1'
        OpenSSL::Digest::Digest
      else
        OpenSSL::Digest
      end
    end
  end
end
