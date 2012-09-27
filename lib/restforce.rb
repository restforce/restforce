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

    # Public: Create a custom Restforce::Client method linked to a custom apex
    # REST service.
    #
    # service - The name of the REST endpoint. For example, if you access your
    #           REST endpoint at /services/apexrest/FieldCase, the service would
    #           be "FieldCase" (default: nil).
    # options - A hash of options (default: {}).
    #           :as - What the method should be named (default: the name of the service).
    # block   - The block to execute when the custom method is called. The
    #           block should always have the first parameter as "path", which
    #           points to the location of the endpoint (e.g. '/services/apexrest/FieldCase').
    #
    # Examples
    #
    #   # Assuming you have an apex class on Salesforce like so:
    #   @RestResource(urlMapping='/ValidateName')
    #   global class RESTCaseController {
    #     @HttpGet
    #     global static Map<String, Boolean> validateName() {
    #       String name = RestContext.request.params.get('name');
    #       List<Account> accounts = [select Id, Name from Account where Name = :name];
    #       return new Map<String, Boolean> { 'valid' => accounts.size() <= 0 };
    #     }
    #   }
    #
    #   # Register a method to utilize this rest endpoint.
    #   Restforce.register('ValidateName', as: :validate_name) do |path, name|
    #     response = get path, name: name
    #     response.body['valid']
    #   end
    #
    #   # Now we can call this method:
    #   client.validate_name('foobar')
    #   # => true
    #   client.validate_name('sForce')
    #   # => false
    def register(service, options = {}, &block)
      options = {
        as: service.to_sym
      }.merge(options)

      Restforce::Client.class_eval do
        define_method options[:as] do |*args|
          args.unshift("/services/apexrest/#{service}")
          instance_exec(*args, &block)
        end
      end
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
