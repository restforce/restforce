# frozen_string_literal: true

module Restforce
  class Middleware::Caching < FaradayMiddleware::Caching
    def call(env)
      expire(cache_key(env)) unless use_cache?
      super
    end

    def expire(key)
      cache&.delete(key)
    end

    # We don't want to cache requests for different clients, so append the
    # oauth token to the cache key.
    def cache_key(env)
      super(env) + hashed_auth_header(env)
    end

    def use_cache?
      @options[:use_cache]
    end

    def hashed_auth_header(env)
      Digest::SHA1.hexdigest(
        env[:request_headers][Restforce::Middleware::Authorization::AUTH_HEADER]
      )
    end
  end
end
