module Restforce
  # Middleware which asserts that the instance_url is always set
  class Middleware::InstanceURL < Restforce::Middleware
    def call(env)
      # If the connection url_prefix isn't set, we must not be authenticated.
      raise Restforce::UnauthorizedError,
            'Connection prefix not set' unless url_prefix_set?

      @app.call(env)
    end

    def url_prefix_set?
      !!(connection.url_prefix && connection.url_prefix.host)
    end
  end
end
