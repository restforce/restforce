module Restforce
  class Middleware::Caching < FaradayMiddleware::Caching

    def call(env)
      expire(cache_key(env)) unless use_cache?
      super
    end

    def expire(key)
      cache.delete(key) if cache
    end

    # We don't want to cache requests for different clients, so append the
    # oauth token to the cache key.
    def cache_key(env)
      super(env) + env[:request_headers][Restforce::Middleware::Authorization::AUTH_HEADER].gsub(/\s/, '')
    end

    def use_cache?
      !@options.has_key?(:use_cache) || @options[:use_cache]
    end

  end
end
