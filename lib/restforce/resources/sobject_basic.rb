# frozen_string_literal: true

module Restforce
  module Resources
    class SObjectBasic < Base
      def to_hash
        {
          method: method.to_s.upcase,
          url: url
        }.merge(get_hash_for(:body))
      end

      class << self
        def path(api_version, sobject_name)
          "/services/data/v#{api_version}/sobjects/#{sobject_name}"
        end

        def build_option_url(opts = {})
          require_arguments(opts, :sobject_name, :api_version)
          options = { api_version: '26.0' }.merge(opts)
          options[:url] ||= path(options[:api_version], options[:sobject_name])
          options
        end
      end
    end
  end
end
