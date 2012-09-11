module Restforce
  class Middleware::Caching < FaradayMiddleware::Caching

    # We don't want to cache requests for different clients, so append the
    # oauth token to the cache key.
    def cache_key(env)
      super(env) + env[:request_headers][Restforce::Middleware::Authorization::AUTH_HEADER].gsub(/\s/, '')
    end

  end
end
