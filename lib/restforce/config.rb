# frozen_string_literal: true

require 'logger'

module Restforce
  class << self
    attr_writer :log

    # Returns the current Configuration
    #
    # Example
    #
    #    Restforce.configuration.username = "username"
    #    Restforce.configuration.password = "password"
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the Configuration
    #
    # Example
    #
    #    Restforce.configure do |config|
    #      config.username = "username"
    #      config.password = "password"
    #    end
    def configure
      yield configuration
    end

    def log?
      @log ||= false
    end

    def log(message)
      return unless Restforce.log?

      configuration.logger.send(configuration.log_level, message)
    end
  end

  class Configuration
    class Option
      attr_reader :configuration, :name, :options

      def self.define(*args)
        new(*args).define
      end

      def initialize(configuration, name, options = {})
        @configuration = configuration
        @name = name
        @options = options
        @default = options.fetch(:default, nil)
      end

      def define
        write_attribute
        define_method if default_provided?
        self
      end

      private

      attr_reader :default
      alias default_provided? default

      def write_attribute
        configuration.send :attr_accessor, name
      end

      def define_method
        our_default = default
        our_name    = name
        configuration.send :define_method, our_name do
          instance_variable_get(:"@#{our_name}") ||
            instance_variable_set(
              :"@#{our_name}",
              our_default.respond_to?(:call) ? our_default.call : our_default
            )
        end
      end
    end

    class << self
      attr_accessor :options

      def option(*args)
        option = Option.define(self, *args)
        (self.options ||= []) << option.name
      end
    end

    option :api_version, default: lambda { ENV.fetch('SALESFORCE_API_VERSION', '26.0') }

    # The username to use during login.
    option :username, default: lambda { ENV.fetch('SALESFORCE_USERNAME', nil) }

    # The password to use during login.
    option :password, default: lambda { ENV.fetch('SALESFORCE_PASSWORD', nil) }

    # The security token to use during login.
    option :security_token, default: lambda {
                                       ENV.fetch('SALESFORCE_SECURITY_TOKEN', nil)
                                     }

    # The OAuth client id
    option :client_id, default: lambda { ENV.fetch('SALESFORCE_CLIENT_ID', nil) }

    # The OAuth client secret
    option :client_secret, default: lambda { ENV.fetch('SALESFORCE_CLIENT_SECRET', nil) }

    # The private key for JWT authentication
    option :jwt_key

    # Set this to true if you're authenticating with a Sandbox instance.
    # Defaults to false.
    option :host, default: lambda { ENV.fetch('SALESFORCE_HOST', 'login.salesforce.com') }

    option :oauth_token
    option :refresh_token
    option :instance_url

    # Set this to an object that responds to read, write and fetch and all GET
    # requests will be cached.
    option :cache

    # The number of times reauthentication should be tried before failing.
    option :authentication_retries, default: 3

    # Set to true if you want responses from Salesforce to be gzip compressed.
    option :compress

    # Set to false if you want to skip conversion to Restforce::Sobjects and
    # Restforce::Collections.
    option :mashify

    # Faraday request read/open timeout.
    option :timeout

    # Faraday adapter to use. Defaults to Faraday.default_adapter.
    option :adapter, default: lambda { Faraday.default_adapter || :net_http }

    option :proxy_uri, default: lambda { ENV.fetch('SALESFORCE_PROXY_URI', nil) }

    # A Proc that is called with the response body after a successful authentication.
    option :authentication_callback

    # Set SSL options
    option :ssl, default: {}

    # A Hash that is converted to HTTP headers
    option :request_headers

    # Set a logger for when Restforce.log is set to true, defaulting to STDOUT
    option :logger, default: ::Logger.new($stdout)

    # Set a log level for logging when Restforce.log is set to true, defaulting to :debug
    option :log_level, default: :debug

    # Set use_cache to false to opt in to caching with client.with_caching
    option :use_cache, default: true

    def options
      self.class.options
    end
  end
end
