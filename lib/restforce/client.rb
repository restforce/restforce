require 'restforce/client/connection'
require 'restforce/client/authentication'
require 'restforce/client/streaming'
require 'restforce/client/picklists'
require 'restforce/client/caching'
require 'restforce/client/canvas'
require 'restforce/client/api'

module Restforce
  class Client
    include Restforce::Client::Connection
    include Restforce::Client::Authentication
    include Restforce::Client::Streaming
    include Restforce::Client::Picklists
    include Restforce::Client::Caching
    include Restforce::Client::Canvas
    include Restforce::Client::API

    # Public: Creates a new client instance
    #
    # opts - A hash of options to be passed in (default: {}).
    #        :username               - The String username to use (required for password authentication).
    #        :password               - The String password to use (required for password authentication).
    #        :security_token         - The String security token to use (required for password authentication).
    #
    #        :oauth_token            - The String oauth access token to authenticate api
    #                                  calls (required unless password
    #                                  authentication is used).
    #        :refresh_token          - The String refresh token to obtain fresh
    #                                  oauth access tokens (required if oauth
    #                                  authentication is used).
    #        :instance_url           - The String base url for all api requests
    #                                  (required if oauth authentication is used).
    #
    #        :client_id              - The oauth client id to use. Needed for both
    #                                  password and oauth authentication
    #        :client_secret          - The oauth client secret to use.
    #
    #        :host                   - The String hostname to use during
    #                                  authentication requests (default: 'login.salesforce.com').
    #
    #        :api_version            - The String REST api version to use (default: '24.0')
    #
    #        :authentication_retries - The number of times that client
    #                                  should attempt to reauthenticate
    #                                  before raising an exception (default: 3).
    #
    #        :compress               - Set to true to have Salesforce compress the response (default: false).
    #        :timeout                - Faraday connection request read/open timeout. (default: nil).
    #
    #        :proxy_uri              - Proxy URI: 'http://proxy.example.com:port' or 'http://user@pass:proxy.example.com:port'
    #
    # Examples
    #
    #   # Initialize a new client using password authentication:
    #   Restforce::Client.new :username => 'user',
    #     :password => 'pass',
    #     :security_token => 'security token',
    #     :client_id => 'client id',
    #     :client_secret => 'client secret'
    #
    #   # Initialize a new client using oauth authentication:
    #   Restforce::Client.new :oauth_token => 'access token',
    #     :refresh_token => 'refresh token',
    #     :instance_url => 'https://na1.salesforce.com',
    #     :client_id => 'client id',
    #     :client_secret => 'client secret'
    #
    #   # Initialize a new client without using any authentication middleware:
    #   Restforce::Client.new :oauth_token => 'access token',
    #     :instance_url => 'https://na1.salesforce.com'
    #
    def initialize(opts = {})
      raise 'Please specify a hash of options' unless opts.is_a?(Hash)
      @options = Hash[Restforce.configuration.options.map { |option| [option, Restforce.configuration.send(option)] }]
      @options.merge! opts
    end

    def instance_url
      authenticate! unless @options[:instance_url]
      @options[:instance_url]
    end

    # Public: Returns a url to the resource.
    #
    # resource - A record that responds to to_sparam or a String/Fixnum.
    #
    # Returns the url to the resource.
    def url(resource)
      "#{instance_url}/#{(resource.respond_to?(:to_sparam) ? resource.to_sparam : resource)}"
    end

    def inspect
      "#<#{self.class} @options=#{@options.inspect}>"
    end
  end
end
