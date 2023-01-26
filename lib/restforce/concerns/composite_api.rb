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
        extend Restforce::Resources::SubrequestBuilder

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
        # opts          - this is where you can pass a :fields list to be returned and/or
        #                 specify some :http_headers ie:
        #                 { http_headers:
        #                   { "If-Modified-Since" => "Tue, 31 May 2016 18:00:00 GMT" } }
        # Returns the Restforce::SObject sobject record.

        define_subrequest :basic_metadata,
                          'Restforce::Resources::SObjectBasic',
                          :get,
                          :sobject_name, :reference_id

        define_subrequest :create,
                          'Restforce::Resources::SObjectBasic',
                          :post,
                          :sobject_name, :reference_id, :body

        # subrequest.find(sobject_name, reference_id, sobject_id, opts = {})
        #
        # sobject_name  - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        # sobject_id    - A Salesforce Id
        # opts          - this is where you can pass a :fields list to be returned and/or
        #                 specify some :http_headers ie:
        #                 { http_headers:
        #                   { "If-Modified-Since" => "Tue, 31 May 2016 18:00:00 GMT" },
        #                   fields: %w[first last email]
        #                 }
        # Returns the Restforce::SObject sobject record.
        define_subrequest :find,
                          'Restforce::Resources::SObjectRows',
                          :get,
                          :sobject_name, :reference_id, :sobject_id

        # subrequest.destroy(sobject_name, reference_id, sobject_id, opts = {})
        #
        # sobject_name  - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        # sobject_id    - A Salesforce Id
        # opts          - this is where you can specify some :http_headers ie:
        #                 { http_headers:
        #                   { "If-Modified-Since" => "Tue, 31 May 2016 18:00:00 GMT" },
        #                 }
        define_subrequest :destroy,
                          'Restforce::Resources::SObjectRows',
                          :delete,
                          :sobject_name, :reference_id, :sobject_id

        # subrequest.update_by_id(sobject_name, reference_id, sobject_id, opts = {})
        #
        # sobject_name  - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        # sobject_id    - A Salesforce Id
        # opts          - this is where you can specify some :http_headers ie:
        #                 { http_headers:
        #                   { "If-Modified-Since" => "Tue, 31 May 2016 18:00:00 GMT" },
        #                 }
        define_subrequest :update_by_id,
                          'Restforce::Resources::SObjectRows',
                          :patch,
                          :sobject_name, :reference_id, :sobject_id

        # subrequest.find_by(sobject_name, reference_id, field_value, field_name,
        #                    opts = {})
        #
        # sobject_name  - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        # field_value   - A Salesforce External Id
        # field_name    - The External Field Name
        # opts          - You can override the api_version
        define_subrequest :find_by,
                          'Restforce::Resources::SObjectRowsByExternalId',
                          :get,
                          :sobject_name, :reference_id, :field_value, :field_name

        # subrequest.upsert_by(sobject_name, reference_id, field_value, field_name,
        #                    body: { first: "John" })
        #
        # sobject_name  - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        # field_value   - A Salesforce External Id
        # field_name    - The External Field Name
        # opts          - here you specify the body
        define_subrequest :upsert_by,
                          'Restforce::Resources::SObjectRowsByExternalId',
                          :patch,
                          :sobject_name, :reference_id, :field_value, :field_name

        # subrequest.delete_by(sobject_name, reference_id, field_value, field_name)
        #
        # sobject_name  - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        # field_value   - A Salesforce External Id
        # field_name    - The External Field Name
        # opts          - You can override the api_version
        define_subrequest :delete_by,
                          'Restforce::Resources::SObjectRowsByExternalId',
                          :delete,
                          :sobject_name, :reference_id, :field_value, :field_name

        # subrequest.query(soql, reference_id,
        #                 http_headers: {"Sforce-Query-Options" => 'batchSize=1000'})
        #
        # soql          - The String containing the soql query
        # reference_id  - The reference id to match with the response
        # opts          - You can override the batch file
        define_subrequest :query,
                          'Restforce::Resources::Query',
                          :get,
                          :soql, :reference_id

        # subrequest.query_all(soql, reference_id,
        #                 http_headers: {"Sforce-Query-Options" => 'batchSize=1000'})
        #
        # soql          - The String containing the soql query
        # reference_id  - The reference id to match with the response
        # opts          - You can override the batch file
        define_subrequest :query_all,
                          'Restforce::Resources::QueryAll',
                          :get,
                          :soql, :reference_id

        def update(sobject, reference_id, attrs)
          id = attrs.fetch(attrs.keys.find { |k, _v| k.to_s.casecmp?('id') }, nil)
          raise ArgumentError, 'Id field missing from attrs.' unless id

          attrs_without_id = attrs.reject { |k, _v| k.to_s.casecmp?('id') }
          update_by_id(sobject, reference_id, id, body: attrs_without_id)
        end

        def upsert(sobject, reference_id, ext_field, attrs)
          raise ArgumentError, 'External id field missing.' unless ext_field

          ext_id = attrs.fetch(attrs.keys.find do |k, _v|
            k.to_s.casecmp?(ext_field.to_s)
          end, nil)
          raise ArgumentError, 'External id missing from attrs.' unless ext_id

          attrs_without_ext_id = attrs.reject { |k, _v| k.to_s.casecmp?(ext_field) }
          upsert_by(sobject, reference_id, ext_id, ext_field, body: attrs_without_ext_id)
        end
      end
    end
  end
end
