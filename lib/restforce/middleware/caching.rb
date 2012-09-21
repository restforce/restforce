module Restforce
  class Middleware::Caching < FaradayMiddleware::Caching

    def call(env)
      perform_caching? ? super : @app.call(env)
    end

    # We don't want to cache requests for different clients, so append the
    # oauth token to the cache key.
    def cache_key(env)
      super(env) + env[:request_headers][Restforce::Middleware::Authorization::AUTH_HEADER].gsub(/\s/, '')
    end

    def perform_caching?
      !@options.has_key?(:perform_caching) || @options[:perform_caching]
    end

  end
end
