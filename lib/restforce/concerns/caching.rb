# frozen_string_literal: true

module Restforce
  module Concerns
    module Caching
      # Public: Runs the block with caching disabled.
      #
      # block - A query/describe/etc.
      #
      # Returns the result of the block
      def without_caching
        options[:use_cache] = false
        yield
      ensure
        options.delete(:use_cache)
      end

      def with_caching
        options[:use_cache] = true
        yield
      ensure
        options[:use_cache] = false
      end

      private

      # Internal: Cache to use for the caching middleware
      def cache
        options[:cache]
      end
    end
  end
end
