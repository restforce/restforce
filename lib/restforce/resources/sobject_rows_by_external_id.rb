# frozen_string_literal: true

module Restforce
  module Resources
    class SObjectRowsByExternalId < Base
      def to_hash
        {
          method: method.to_s.upcase,
          url: url
        }.merge(
          get_hash_for(:body)
        )
      end

      class << self
        def path(api_version, sobject_name, field_name, field_value)
          "/services/data/v#{api_version}/sobjects/" \
            "#{sobject_name}/#{field_name}/#{field_value}"
        end

        def build_option_url(opts = {})
          Restforce::Resources::Requirements.require_options(opts,
                                                             :api_version,
                                                             :sobject_name,
                                                             :field_name,
                                                             :field_value)
          options = { api_version: '26.0' }.merge(opts)
          options[:url] ||= path(options[:api_version],
                                 options[:sobject_name],
                                 options[:field_name],
                                 options[:field_value])
          options
        end
      end
    end
  end
end
