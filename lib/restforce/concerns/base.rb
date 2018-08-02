# frozen_string_literal: true

module Restforce
  module Concerns
    module Base
      attr_reader :options

      # Public: Creates a new client instance
      #
      # opts - A hash of options to be passed in (default: {}).
      #        :username                - The String username to use (required for
      #                                   password authentication).
      #        :password                - The String password to use (required for
      #                                   password authentication).
      #        :security_token          - The String security token to use (required for
      #                                   password authentication).
      #
      #        :oauth_token             - The String oauth access token to authenticate
      #                                   API calls (required unless password
      #                                   authentication is used).
      #        :refresh_token           - The String refresh token to obtain fresh
      #                                   OAuth access tokens (required if oauth
      #                                   authentication is used).
      #        :instance_url            - The String base url for all api requests
      #                                   (required if oauth authentication is used).
      #
      #        :client_id               - The oauth client id to use. Needed for both
      #                                   password and oauth authentication
      #        :client_secret           - The oauth client secret to use.
      #
      #        :host                    - The String hostname to use during
      #                                   authentication requests
      #                                   (default: 'login.salesforce.com').
      #
      #        :api_version             - The String REST api version to use
      #                                   (default: '24.0')
      #
      #        :authentication_retries  - The number of times that client
      #                                   should attempt to reauthenticate
      #                                   before raising an exception (default: 3).
      #
      #        :compress                - Set to true to have Salesforce compress the
      #                                   response (default: false).
      #        :mashify                 - Set to false to skip the conversion of
      #                                   Salesforce responses to Restforce::Sobjects and
      #                                   Restforce::Collections. (default: nil).
      #        :timeout                 - Faraday connection request read/open timeout.
      #                                   (default: nil).
      #
      #        :proxy_uri               - Proxy URI: 'http://proxy.example.com:port' or
      #                                   'http://user@pass:proxy.example.com:port'
      #
      #        :authentication_callback - A Proc that is called with the response body
      #                                   after a successful authentication.
      #
      #        :request_headers         - A hash containing custom headers that will be
      #                                   appended to each request

      def initialize(opts = {})
        raise ArgumentError, 'Please specify a hash of options' unless opts.is_a?(Hash)

        @options = Hash[Restforce.configuration.options.map do |option|
          [option, Restforce.configuration.send(option)]
        end]

        @options.merge! opts
        yield builder if block_given?
      end

      def instance_url
        authenticate! unless options[:instance_url]
        options[:instance_url]
      end

      def inspect
        "#<#{self.class} @options=#{@options.inspect}>"
      end
    end
  end
end
