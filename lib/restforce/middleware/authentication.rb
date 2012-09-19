module Restforce

  # Faraday middleware that allows for on the fly authentication of requests.
  # When a request fails (ie. A status of 401 is returned). The middleware
  # will attempt to either reauthenticate (username and password) or refresh
  # the oauth access token (if a refresh token is present).
  class Middleware::Authentication < Restforce::Middleware

    def call(env)
      request_body = env[:body]
      request = env[:request]
      begin
        return authenticate! if force_authenticate?(env)
        @app.call(env)
      rescue Restforce::UnauthorizedError
        authenticate!
        env[:body] = request_body
        env[:request] = request
        @app.call(env)
      end
    end

    def authenticate!
      raise 'must subclass'
    end

    def connection
      @connection ||= Faraday.new(:url => "https://#{@options[:host]}") do |builder|
        builder.response :json
        builder.use Restforce::Middleware::Logger, Restforce.configuration.logger if Restforce.log?
        builder.adapter Faraday.default_adapter
      end
    end

    def force_authenticate?(env)
      env[:request_headers] && env[:request_headers]['X-ForceAuthenticate']
    end

    def error_message(response)
      "#{response.body['error']}: #{response.body['error_description']}"
    end
  
  end

end
