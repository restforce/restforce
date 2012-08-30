module Restforce
  class Client

    def initialize(options)
      raise 'Please specify a hash of options' unless options.is_a?(Hash)
      @options = {}.tap do |options|
        [:username, :password, :security_token, :client_id, :client_secret, :host,
         :api_version, :oauth_token, :refresh_token, :instance_url].each do |option|
          options[option] = Restforce.configuration.send option
        end
      end
      @options.merge!(options)
    end

    def describe_sobjects
      response = get api_path('sobjects')
      response.body['sobjects']
    end

    def list_sobjects
      describe_sobjects.collect { |sobject| sobject['name'] }
    end

    # Helper methods for performing abritrary actions against the API using
    # various HTTP verbs
    [:get, :post, :put, :delete].each do |method|
      define_method method do |*args|
        connection.send method, *args
      end
    end

  private

    # Returns a path to an api endpoint
    #
    # Example
    #
    #   api_path('sobjects')
    #   # => '/services/data/v24.0/sobjects'
    def api_path(path)
      "/services/data/v#{@options[:api_version]}/#{path}"
    end

    # Internal faraday connection where all requests go through
    def connection
      @connection ||= Faraday.new(:url => "https://#{@options[:instance_url]}") do |builder|
        builder.request :json
        builder.response :json
        builder.use authentication_middleware, @options
        builder.use Restforce::Middleware::Authorization, @options
        builder.use Restforce::Middleware::InstanceURL, @options
        builder.response :raise_error
        builder.adapter Faraday.default_adapter
      end
    end

    # Determins what middleware will be used based on the options provided
    def authentication_middleware
      if username_password?
        Restforce::Middleware::PasswordAuthentication
      elsif oauth_refresh?
        Restforce::Middleware::OAuthRefreshAuthentication
      end
    end

    # Returns true if username/password (autonomous) flow should be used for
    # authentication.
    def username_password?
      @options[:username] &&
        @options[:password] &&
        @options[:security_token] &&
        @options[:client_id] &&
        @options[:client_secret]
    end

    # Returns true if oauth token refresh flow should be used for
    # authentication.
    def oauth_refresh?
      @options[:oauth_token] && @options[:refresh_token]
    end

  end
end
