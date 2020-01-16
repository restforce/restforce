# frozen_string_literal: true

module Restforce
  # Middleware which asserts that the instance_url is always set
  class Middleware::InstanceURL < Restforce::Middleware
    def call(env)
      # If the connection url_prefix isn't set, we must not be authenticated.
      unless url_prefix_set?
        raise Restforce::UnauthorizedError,
              'Connection prefix not set'
      end

      @app.call(env)
    end

    def url_prefix_set?
      !!connection.url_prefix&.host
    end
  end
end
