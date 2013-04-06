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
      Restforce.configuration.logger.send :debug, message
    end
  end

  class Configuration
    class << self
      attr_accessor :options

      def option(name, options = {})
        default = options.fetch(:default, nil)
        attr_accessor name
        define_method name do
          instance_variable_get(:"@#{name}") ||
            instance_variable_set(:"@#{name}", default.respond_to?(:call) ? default.call : default)
        end if default
        self.options ||= []
        self.options << name
      end
    end

    option :api_version, :default => '26.0'

    # The username to use during login.
    option :username, :default => lambda { ENV['SALESFORCE_USERNAME'] }

    # The password to use during login.
    option :password, :default => lambda { ENV['SALESFORCE_PASSWORD'] }

    # The security token to use during login.
    option :security_token, :default => lambda { ENV['SALESFORCE_SECURITY_TOKEN'] }

    # The OAuth client id
    option :client_id, :default => lambda { ENV['SALESFORCE_CLIENT_ID'] }

    # The OAuth client secret
    option :client_secret, :default => lambda { ENV['SALESFORCE_CLIENT_SECRET'] }

    # Set this to true if you're authenticating with a Sandbox instance.
    # Defaults to false.
    option :host, :default => 'login.salesforce.com'

    option :oauth_token
    option :refresh_token
    option :instance_url

    # Set this to an object that responds to read, write and fetch and all GET
    # requests will be cached.
    option :cache

    # The number of times reauthentication should be tried before failing.
    option :authentication_retries, :default => 3

    # Set to true if you want responses from Salesforce to be gzip compressed.
    option :compress

    # Faraday request read/open timeout.
    option :timeout

    # Faraday adapter to use. Defaults to Faraday.default_adapter.
    option :adapter, :default => lambda { Faraday.default_adapter }

    option :proxy_uri, :default => lambda { ENV['PROXY_URI'] }

    def logger
      @logger ||= ::Logger.new STDOUT
    end

    def options
      self.class.options
    end
  end
end
