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
      response = api_get('sobjects')
      response.body['sobjects']
    end

    # Returns an array of the names of all sobjects on the org
    #
    # Example
    #
    #   # get the names of all sobjects on the org
    #   client.list_sobjects
    #   # => ['Account', 'Lead', ... ]
    def list_sobjects
      describe_sobjects.collect { |sobject| sobject['name'] }
    end
    
    def describe(sobject)
    end
    
    def query(query)
    end
    
    def search(term)
    end
    
    def find(sobject, id)
    end
    
    def create(sobject, attrs)
    end

    def update(sobject, attrs)
    end

    def destroy(sobject, id)
    end

    # Helper methods for performing abritrary actions against the API using
    # various HTTP verbs.
    #
    # Example
    #
    #   # Perform a get request
    #   client.get '/services/data/v24.0/sobjects'
    #   client.api_get 'sobjects'
    #
    #   # Perform a post request
    #   client.post '/services/data/v24.0/sobjects/Account', { ... }
    #   client.api_post 'sobjects/Account', { ... }
    #
    #   # Perform a put request
    #   client.put '/services/data/v24.0/sobjects/Account/001D000000INjVe', { ... }
    #   client.api_put 'sobjects/Account/001D000000INjVe', { ... }
    #
    #   # Perform a delete request
    #   client.delete '/services/data/v24.0/sobjects/Account/001D000000INjVe'
    #   client.api_delete 'sobjects/Account/001D000000INjVe'
    [:get, :post, :put, :delete, :patch].each do |method|
      define_method method do |*args|
        begin
          connection.send(method, *args)
        rescue Restforce::InstanceURLError
          connection.url_prefix = @options[:instance_url]
          connection.send(method, *args)
        end
      end

      define_method :"api_#{method}" do |*args|
        args[0] = api_path(args[0])
        send(method, *args)
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
      @connection ||= Faraday.new do |builder|
        builder.request :json
        builder.response :json
        builder.use authentication_middleware, self, @options
        builder.use Restforce::Middleware::Authorization, self, @options
        builder.use Restforce::Middleware::InstanceURL, self, @options
        builder.response :raise_error
        builder.response :logger, Restforce.configuration.logger if Restforce.log?
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
      @options[:oauth_token] &&
        @options[:refresh_token] &&
        @options[:client_id] &&
        @options[:client_secret]
    end

  end
end
