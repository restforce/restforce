module Restforce

  # Faraday middleware that allows for on the fly authentication of requests.
  # When a request fails (ie. A status of 401 is returned). The middleware
  # will attempt to either reauthenticate (username and password) or refresh
  # the oauth access token (if a refresh token is present).
  class Middleware::Authentication < Restforce::Middleware

    def call(env)
      begin
        @app.call(env)
      rescue Restforce::UnauthorizedError
        authenticate!
        @app.call(env)
      end
    end

    def authenticate!
      raise 'must subclass'
    end

    def connection
      @connection ||= Faraday.new(:url => "https://#{@options[:host]}") do |builder|
        builder.response :json
        builder.response :logger, Restforce.configuration.logger if Restforce.log?
        builder.adapter Faraday.default_adapter
      end
    end
  
  end

end
