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
    attr_accessor :api_version
    # The username to use during login.
    attr_accessor :username
    # The password to use during login.
    attr_accessor :password
    # The security token to use during login.
    attr_accessor :security_token
    # The OAuth client id
    attr_accessor :client_id
    # The OAuth client secret
    attr_accessor :client_secret
    # Set this to true if you're authenticating with a Sandbox instance.
    # Defaults to false.
    attr_accessor :host

    attr_accessor :oauth_token
    attr_accessor :refresh_token
    attr_accessor :instance_url

    # Set this to an object that responds to read, write and fetch and all GET
    # requests will be cached.
    attr_accessor :cache

    # The number of times reauthentication should be tried before failing.
    attr_accessor :authentication_retries

    # Set to true if you want responses from Salesforce to be gzip compressed.
    attr_accessor :compress

    # Faraday request read/open timeout.
    attr_accessor :timeout

    def api_version
      @api_version ||= '26.0'
    end

    def username
      @username ||= ENV['SALESFORCE_USERNAME']
    end

    def password
      @password ||= ENV['SALESFORCE_PASSWORD']
    end

    def security_token
      @security_token ||= ENV['SALESFORCE_SECURITY_TOKEN']
    end

    def client_id
      @client_id ||= ENV['SALESFORCE_CLIENT_ID']
    end

    def client_secret
      @client_secret ||= ENV['SALESFORCE_CLIENT_SECRET']
    end

    def host
      @host ||= 'login.salesforce.com'
    end

    def authentication_retries
      @authentication_retries ||= 3
    end

    def logger
      @logger ||= ::Logger.new STDOUT
    end
  end
end
