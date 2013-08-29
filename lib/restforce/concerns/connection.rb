module Restforce
  module Concerns
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
      alias_method :builder, :middleware

    private

      # Internal: Internal faraday connection where all requests go through
      def connection
        @connection ||= Faraday.new(options[:instance_url], connection_options) do |builder|
          # Parses JSON into Hashie::Mash structures.
          builder.use      Restforce::Middleware::Mashify, self, options unless (options[:mashify] == false)
          # Handles multipart file uploads for blobs.
          builder.use      Restforce::Middleware::Multipart
          # Converts the request into JSON.
          builder.request  :json
          # Handles reauthentication for 403 responses.
          builder.use      authentication_middleware, self, options if authentication_middleware
          # Sets the oauth token in the headers.
          builder.use      Restforce::Middleware::Authorization, self, options
          # Ensures the instance url is set.
          builder.use      Restforce::Middleware::InstanceURL, self, options
          # Parses returned JSON response into a hash.
          builder.response :json, :content_type => /\bjson$/
          # Caches GET requests.
          builder.use      Restforce::Middleware::Caching, cache, options if cache
          # Follows 30x redirects.
          builder.use      FaradayMiddleware::FollowRedirects
          # Raises errors for 40x responses.
          builder.use      Restforce::Middleware::RaiseError
          # Log request/responses
          builder.use      Restforce::Middleware::Logger, Restforce.configuration.logger, options if Restforce.log?
          # Compress/Decompress the request/response
          builder.use      Restforce::Middleware::Gzip, self, options

          builder.adapter  adapter
        end
      end

      def adapter
        Restforce.configuration.adapter
      end

      # Internal: Faraday Connection options
      def connection_options
        { :request => {
            :timeout => options[:timeout],
            :open_timeout => options[:timeout] },
          :proxy => options[:proxy_uri]
        }
      end

      # Internal: Returns true if the middlware stack includes the
      # Restforce::Middleware::Mashify middleware.
      def mashify?
        middleware.handlers.index(Restforce::Middleware::Mashify)
      end

    end
  end
end
