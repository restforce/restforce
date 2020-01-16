# frozen_string_literal: true

require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module BatchAPI
      extend Restforce::Concerns::Verbs

      define_verbs :post

      def batch(halt_on_error: false)
        subrequests = Subrequests.new(options)
        yield(subrequests)
        subrequests.requests.each_slice(25).map do |requests|
          properties = {
            batchRequests: requests,
            haltOnError: halt_on_error
          }
          response = api_post('composite/batch', properties.to_json)
          body = response.body
          results = body['results']
          if halt_on_error && body['hasErrors']
            last_error_index = results.rindex { |result| result['statusCode'] != 412 }
            last_error = results[last_error_index]
            raise BatchAPIError, last_error['result'][0]['errorCode']
          end
          results.map(&:compact)
        end.flatten
      end

      def batch!(&block)
        batch(halt_on_error: true, &block)
      end

      class Subrequests
        def initialize(options)
          @options = options
          @requests = []
        end
        attr_reader :options, :requests

        def create(sobject, attrs)
          requests << { method: 'POST', url: batch_api_path(sobject), richInput: attrs }
        end

        def update(sobject, attrs)
          id = attrs.fetch(attrs.keys.find { |k, v| k.to_s.casecmp?('id') }, nil)
          raise ArgumentError, 'Id field missing from attrs.' unless id

          attrs_without_id = attrs.reject { |k, v| k.to_s.casecmp?('id') }
          requests << {
            method: 'PATCH',
            url: batch_api_path("#{sobject}/#{id}"),
            richInput: attrs_without_id
          }
        end

        def destroy(sobject, id)
          requests << { method: 'DELETE', url: batch_api_path("#{sobject}/#{id}") }
        end

        def upsert(sobject, ext_field, attrs)
          raise ArgumentError, 'External id field missing.' unless ext_field

          ext_id = attrs.fetch(attrs.keys.find { |k, v|
            k.to_s.casecmp?(ext_field.to_s)
          }, nil)
          raise ArgumentError, 'External id missing from attrs.' unless ext_id

          attrs_without_ext_id = attrs.reject { |k, v| k.to_s.casecmp?(ext_field) }
          requests << {
            method: 'PATCH',
            url: batch_api_path("#{sobject}/#{ext_field}/#{ext_id}"),
            richInput: attrs_without_ext_id
          }
        end

        private

        def batch_api_path(path)
          "v#{options[:api_version]}/sobjects/#{path}"
        end
      end
    end
  end
end
