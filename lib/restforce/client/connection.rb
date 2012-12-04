module Restforce
  class Client
    module Connection

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
