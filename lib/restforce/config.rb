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

    def initialize
      @api_version ||= '24.0'
      @host        ||= 'login.salesforce.com'
    end

    def logger
      @logger ||= ::Logger.new STDOUT
    end
  end
end
