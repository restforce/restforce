# frozen_string_literal: true

module Restforce
  module Resources
    class Query < Base
      def to_hash
        {
          method: method.to_s.upcase,
          url: url
        }
      end

      class << self
        def path(api_version, soql)
          encoded_path("/services/data/v#{api_version}/query",
                       { q: soql })
        end

        def build_option_url(opts = {})
          require_arguments(opts, :api_version, :soql)
          options = { api_version: '26.0' }.merge(opts)
          options[:url] ||= path(options[:api_version], options[:soql])
          options
        end
      end
    end
  end
end
