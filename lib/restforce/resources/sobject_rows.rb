# frozen_string_literal: true

module Restforce
  module Resources
    class SObjectRows < Base
      def to_hash
        {
          method: method.to_s.upcase,
          url: url
        }.merge(
          get_hash_for(:body)
        ).merge(
          get_hash_for(:http_headers, :httpHeaders)
        )
      end

      class << self
        def path(api_version, sobject_name, sobject_id, fields = [])
          fields_value = ERB::Util.url_encode(Array(fields).join(','))
          fields_query = fields_value.empty? ? '' : "?fields=#{fields_value}"
          "/services/data/v#{api_version}/sobjects/" \
            "#{sobject_name}/#{sobject_id}#{fields_query}"
        end

        def build_option_url(opts = {})
          Restforce::Resources::Requirements.require_options(opts,
                                                             :sobject_name,
                                                             :api_version, :id)
          options = { api_version: '26.0' }.merge(opts)
          options[:url] ||= path(options[:api_version],
                                 options[:sobject_name],
                                 options[:id],
                                 options.delete(:fields))
          options
        end
      end
    end
  end
end
