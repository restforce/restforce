module MultiJson
  module OptionsCache
    class Store
      # Normally MultiJson is used with a few option sets for both dump/load
      # methods. When options are generated dynamically though, every call would
      # cause a cache miss and the cache would grow indefinitely. To prevent
      # this, we just reset the cache every time the number of keys outgrows
      # 1000.
      MAX_CACHE_SIZE = 1000
      private_constant :MAX_CACHE_SIZE

      def initialize
        @cache = {}
        @mutex = Mutex.new
      end

      def reset
        @mutex.synchronize do
          @cache = {}
        end
      end

      def fetch(key, &block)
        @mutex.synchronize do
          return @cache[key] if @cache.key?(key)
        end

        value = yield

        @mutex.synchronize do
          if @cache.key?(key)
            # We ran into a race condition, keep the existing value
            @cache[key]
          else
            @cache.clear if @cache.size >= MAX_CACHE_SIZE
            @cache[key] = value
          end
        end
      end
    end

    class << self
      attr_reader :dump, :load

      def reset
        @dump = Store.new
        @load = Store.new
      end
    end

    reset
  end
end
