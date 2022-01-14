# frozen_string_literal: true

require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module CompositeAPI
      extend Restforce::Concerns::Verbs

      define_verbs :post

      def composite(all_or_none: false, collate_subrequests: false)
        subrequests = Subrequests.new(options)
        yield(subrequests)

        if subrequests.requests.length > 25
          raise ArgumentError, 'Cannot have more than 25 subrequests.'
        end

        properties = {
          compositeRequest: subrequests.requests,
          allOrNone: all_or_none,
          collateSubrequests: collate_subrequests
        }
        response = api_post('composite', properties.to_json)

        results = response.body['compositeResponse']
        has_errors = results.any? { |result| result['httpStatusCode'].digits.last == 4 }
        if all_or_none && has_errors
          last_error_index = results.rindex { |result| result['httpStatusCode'] != 412 }
          last_error = results[last_error_index]
          raise CompositeAPIError, last_error['body'][0]['errorCode']
        end

        results
      end

      def composite!(collate_subrequests: false, &block)
        composite(all_or_none: true, collate_subrequests: collate_subrequests, &block)
      end

      class Subrequests
        def initialize(options)
          @options = options
          @requests = []
        end
        attr_reader :options, :requests

        def create(sobject, reference_id, attrs)
          requests << {
            method: 'POST',
            url: composite_api_path(sobject),
            body: attrs,
            referenceId: reference_id
          }
        end

        def update(sobject, reference_id, attrs)
          id = attrs.fetch(attrs.keys.find { |k, _v| k.to_s.casecmp?('id') }, nil)
          raise ArgumentError, 'Id field missing from attrs.' unless id

          attrs_without_id = attrs.reject { |k, _v| k.to_s.casecmp?('id') }
          requests << {
            method: 'PATCH',
            url: composite_api_path("#{sobject}/#{id}"),
            body: attrs_without_id,
            referenceId: reference_id
          }
        end

        def destroy(sobject, reference_id, id)
          requests << {
            method: 'DELETE',
            url: composite_api_path("#{sobject}/#{id}"),
            referenceId: reference_id
          }
        end

        def upsert(sobject, reference_id, ext_field, attrs)
          raise ArgumentError, 'External id field missing.' unless ext_field

          ext_id = attrs.fetch(attrs.keys.find do |k, _v|
            k.to_s.casecmp?(ext_field.to_s)
          end, nil)
          raise ArgumentError, 'External id missing from attrs.' unless ext_id

          attrs_without_ext_id = attrs.reject { |k, _v| k.to_s.casecmp?(ext_field) }
          requests << {
            method: 'PATCH',
            url: composite_api_path("#{sobject}/#{ext_field}/#{ext_id}"),
            body: attrs_without_ext_id,
            referenceId: reference_id
          }
        end

        private

        def composite_api_path(path)
          "/services/data/v#{options[:api_version]}/sobjects/#{path}"
        end
      end
    end
  end
end
