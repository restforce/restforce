# frozen_string_literal: true

module Restforce
  # Piece of middleware that simply injects the OAuth token into the request
  # headers.
  class Middleware::Authorization < Restforce::Middleware
    AUTH_HEADER = 'Authorization'

    def call(env)
      env[:request_headers][AUTH_HEADER] = %(OAuth #{token})
      @app.call(env)
    end

    def token
      @options[:oauth_token]
    end
  end
end
