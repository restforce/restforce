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
          raise CompositeAPIError.new(last_error['body'][0]['errorCode'], response)
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

        # Public: Finds a single record and returns all fields.
        #
        # sobject       - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        # id            - 'xxx'
        # field_name    - the field to query by. Must be unique in the table
        # opts          - this is where you can pass a :fields list to be returned or
        #                 specify some :http_headers ie:
        #                 { http_headers:
        #                   { "If-Modified-Since" => "Tue, 31 May 2016 18:00:00 GMT" } }
        # Returns the Restforce::SObject sobject record.
        def find(sobject, reference_id, id, field_name = 'id', opts = {})
          fields = opts.delete(:fields) || ''

          http_headers_present = opts[:http_headers] && !opts[:http_headers].empty?
          http_headers = http_headers_present ? { httpHeaders: opts[:http_headers] } : {}
          params = fields.empty? ? {} : { fields: fields.join(',') }
          url = if field_name.to_s.casecmp?('id')
                  "#{sobject}/#{id}"
                else
                  "#{sobject}/#{field_name}/#{id}"
                end
          requests << {
            method: 'GET',
            url: encoded_path(composite_api_path(url), params),
            referenceId: reference_id
          }.merge(http_headers)
        end

        def query(soql, reference_id)
          requests << {
            method: 'GET',
            url: encoded_path("/services/data/v#{options[:api_version]}/query",
                              { q: soql }),
            referenceId: reference_id
          }
        end

        def query_all(soql, reference_id)
          requests << {
            method: 'GET',
            url: encoded_path("/services/data/v#{options[:api_version]}/queryAll",
                              { q: soql }),
            referenceId: reference_id
          }
        end

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

        def composite_api_path(path)
          "/services/data/v#{options[:api_version]}/sobjects/#{path}"
        end
      end
    end
  end
end
