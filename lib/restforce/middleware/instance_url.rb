module Restforce

  # Middleware which asserts that the instance_url is always set
  class Middleware::InstanceURL < Restforce::Middleware

    def call(env)
      # If the connection url_prefix isn't set, we must not be authenticated.
      raise Restforce::UnauthorizedError, 'instance url not set' unless connection.url_prefix

      @app.call(env)
    end
  
  end

end
