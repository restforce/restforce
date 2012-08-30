module Restforce
  module Middleware

    # Middleware that sets the request URI to use the instance_url
    class InstanceURL < Faraday::Middleware

      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        raise Faraday::Error::ClientError, 'instance url not set' unless @options[:instance_url]
        env[:url].hostname = instance_url.hostname
        env[:url].scheme   = instance_url.scheme
        @app.call(env)
      end

      def instance_url
        URI.parse(@options[:instance_url])
      end
    
    end

  end
end
