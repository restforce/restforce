# frozen_string_literal: true

module Restforce
  module Resources
    class Requirements
      class << self
        def require_options(opts, *keys)
          keys.each do |key|
            raise ArgumentError, "You must include a #{key}" unless opts[key]
          end
        end
      end
    end

    class Base
      attr_accessor :method, :opts

      def initialize(method, opts = {})
        @method = method
        @opts = opts
      end

      def to_request
        if reference_id.nil?
          raise ArgumentError, 'Must pass a reference id to be used as a subrequest.'
        end

        to_hash.merge({ referenceId: reference_id })
      end

      def to_hash
        {
          method: method.to_s.upcase,
          url: url
        }
      end

      class << self
        def encoded_path(path, params = {})
          [
            path,
            params.empty? ? nil : '?',
            # we don't want to encode reference_ids ie: '@{ref1.name}'
            unescape_reference_ids(URI.encode_www_form(params))
          ].join
        end

        # Even though SF documentation says query parameters must be URL encoded,
        # if you do so and include a reference_id syntax, You'll get a malformed
        # query because Salesforce doesn't fully URL decode everything
        # I suspect they look for reference_ids before decoding the url
        def unescape_reference_ids(str)
          str.gsub(/%40%7B([\w.%]+)%7D/) do
            "@{#{::Regexp.last_match(1).gsub(/%5B/, '[').gsub(/%5D/, ']')}}"
          end
        end

        def build_option_url(opts = {})
          { api_version: '26.0' }.merge(opts)
        end
      end

      protected

      def get_hash_for(key, as = key)
        respond_to?(key) && !send(key)&.empty? ? { as => send(key) } : {}
      end

      def respond_to_missing?(method, include_private = false)
        if opts&.key?(method)
          true
        else
          super
        end
      end

      def method_missing(method, *args, &block)
        if opts&.key?(method)
          opts[method]
        else
          super
        end
      end
    end
  end
end
