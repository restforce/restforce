module Restforce
  module Middleware

    # Piece of middleware that simply injects the OAuth token into the request
    # headers.
    class Authorization < Faraday::Middleware
      AUTH_HEADER = 'Authorization'.freeze

      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        env[:request_headers][AUTH_HEADER] = %(OAuth #{token})
        @app.call(env)
      end

      def token
        @options[:oauth_token]
      end
    
    end

  end
end
