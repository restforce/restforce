module Restforce
  class Client
    module Connection

      # Public: Helper methods for performing arbitrary actions against the API using
      # various HTTP verbs.
      #
      # Examples
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
      #
      # Returns the Faraday::Response.
      [:get, :post, :put, :delete, :patch].each do |method|
        define_method method do |*args|
          retries = @options[:authentication_retries]
          begin
            connection.send(method, *args)
          rescue Restforce::UnauthorizedError
            if retries > 0
              retries -= 1
              connection.url_prefix = @options[:instance_url]
              retry
            end
            raise
          end
        end

        define_method :"api_#{method}" do |*args|
          args[0] = api_path(args[0])
          send(method, *args)
        end
      end

      # Public: The Faraday::Builder instance used for the middleware stack. This
      # can be used to insert an custom middleware.
      #
      # Examples
      #
      #   # Add the instrumentation middleware for Rails.
      #   client.middleware.use FaradayMiddleware::Instrumentation
      #
      # Returns the Faraday::Builder for the Faraday connection.
      def middleware
        connection.builder
      end

    private

      # Internal: Returns a path to an api endpoint
      #
      # Examples
      #
      #   api_path('sobjects')
      #   # => '/services/data/v24.0/sobjects'
      def api_path(path)
        "/services/data/v#{@options[:api_version]}/#{path}"
      end

      # Internal: Internal faraday connection where all requests go through
      def connection
        @connection ||= Faraday.new(@options[:instance_url]) do |builder|
          builder.use      Restforce::Middleware::Mashify, self, @options
          builder.use      Restforce::Middleware::Multipart
          builder.request  :json
          builder.use      authentication_middleware, self, @options if authentication_middleware
          builder.use      Restforce::Middleware::Authorization, self, @options
          builder.use      Restforce::Middleware::InstanceURL, self, @options
          builder.response :json
          builder.use      Restforce::Middleware::Caching, cache, @options if cache
          builder.use      FaradayMiddleware::FollowRedirects
          builder.use      Restforce::Middleware::RaiseError
          builder.use      Restforce::Middleware::Logger, Restforce.configuration.logger, @options if Restforce.log?
          builder.use      Restforce::Middleware::Gzip, self, @options
          builder.adapter  Faraday.default_adapter
        end
      end

      # Internal: Cache to use for the caching middleware
      def cache
        @options[:cache]
      end

      # Internal: Returns true if the middlware stack includes the
      # Restforce::Middleware::Mashify middleware.
      def mashify?
        middleware.handlers.index(Restforce::Middleware::Mashify)
      end

      # Internal: Errors that should be rescued from in non-bang methods
      def exceptions
        [Faraday::Error::ClientError]
      end

    end
  end
end
