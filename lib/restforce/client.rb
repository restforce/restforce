require 'restforce/client/connection'
require 'restforce/client/authentication'
require 'restforce/client/streaming'
require 'restforce/client/caching'
require 'restforce/client/canvas'
require 'restforce/client/api'

module Restforce
  class Client
    include Restforce::Client::Connection
    include Restforce::Client::Authentication
    include Restforce::Client::Streaming
    include Restforce::Client::Caching
    include Restforce::Client::Canvas
    include Restforce::Client::API

    OPTIONS = [:username, :password, :security_token, :client_id, :client_secret, :host, :compress,
       :api_version, :oauth_token, :refresh_token, :instance_url, :cache, :authentication_retries]

    # Public: Creates a new client instance
    #
    # opts - A hash of options to be passed in (default: {}).
    #           :username               - The String username to use (required for password authentication).
    #           :password               - The String password to use (required for password authentication).
    #           :security_token         - The String security token to use 
    #                                     (required for password authentication).
    #
    #           :oauth_token            - The String oauth access token to authenticate api
    #                                     calls (required unless password
    #                                     authentication is used).
    #           :refresh_token          - The String refresh token to obtain fresh
    #                                     oauth access tokens (required if oauth
    #                                     authentication is used).
    #           :instance_url           - The String base url for all api requests
    #                                     (required if oauth authentication is used).
    #
    #           :client_id              - The oauth client id to use. Needed for both
    #                                     password and oauth authentication
    #           :client_secret          - The oauth client secret to use.
    #
    #           :host                   - The String hostname to use during
    #                                     authentication requests (default: 'login.salesforce.com').
    #
    #           :api_version            - The String REST api version to use (default: '24.0')
    #
    #           :authentication_retries - The number of times that client
    #                                     should attempt to reauthenticate
    #                                     before raising an exception (default: 3).
    #
    #           :compress               - Set to true to have Salesforce compress the
    #                                     response (default: false).
    #
    # Examples
    #
    #   # Initialize a new client using password authentication:
    #   Restforce::Client.new :username => 'user',
    #     :password => 'pass',
    #     :security_token => 'security token',
    #     :client_id => 'client id',
    #     :client_secret => 'client secret'
    #   # => #<Restforce::Client:0x007f934aa2dc28 @options={ ... }>
    #
    #   # Initialize a new client using oauth authentication:
    #   Restforce::Client.new :oauth_token => 'access token',
    #     :refresh_token => 'refresh token',
    #     :instance_url => 'https://na1.salesforce.com',
    #     :client_id => 'client id',
    #     :client_secret => 'client secret'
    #   # => #<Restforce::Client:0x007f934aaaa0e8 @options={ ... }>
    #
    #   # Initialize a new client with using any authentication middleware:
    #   Restforce::Client.new :oauth_token => 'access token',
    #     :instance_url => 'https://na1.salesforce.com'
    #   # => #<Restforce::Client:0x007f934aab9980 @options={ ... }>
    def initialize(opts = {})
      raise 'Please specify a hash of options' unless opts.is_a?(Hash)
      @options = Hash[OPTIONS.map { |option| [option, Restforce.configuration.send(option)] }]
      @options.merge! opts
    end
  end
end
