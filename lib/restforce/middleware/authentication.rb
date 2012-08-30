module Restforce
  module Middleware

    # Faraday middleware that allows for on the fly authentication of requests.
    # When a request fails (ie. A status of 401 is returned). The middleware
    # will attempt to either reauthenticate (username and password) or refresh
    # the oauth access token (if a refresh token is present).
    class Authentication < Faraday::Middleware

      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        begin
          @app.call(env)
        rescue Faraday::Error::ClientError
          authenticate!
          @app.call(env)
        end
      end

      def connection
        @connection ||= Faraday.new(:url => "https://#{@options[:host]}") do |builder|
          builder.request :json
          builder.response :json
          builder.adapter Faraday.default_adapter
        end
        @connection
      end
    
    end

  end
end
