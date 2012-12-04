module Restforce
  class Client
    module Caching

      # Public: Runs the block with caching disabled.
      #
      # block - A query/describe/etc.
      #
      # Returns the result of the block
      def without_caching(&block)
        @options[:perform_caching] = false
        block.call
      ensure
        @options.delete(:perform_caching)
      end

    end
  end
end
