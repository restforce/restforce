module Restforce
  module Middleware

    # Middleware that sets the request URI to use the instance_url
    class InstanceURL < Faraday::Middleware

      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        env[:url].hostname = instance_url.hostname
        @app.call(env)
      end

      def instance_url
        URI.parse(@options[:instance_url])
      end
    
    end

  end
end
