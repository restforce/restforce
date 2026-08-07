# frozen_string_literal: true

require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module SubRequests
      class UniqueNameSet
        extend Forwardable
        def_delegators :@values, :size, :empty?, :length, :each, :first, :last, :[]

        def initialize(name)
          @name = name
          @values = []
          @keys = {}
        end

        def <<(val)
          raise ArgumentError, "The #{@name} #{val} is already in use." if @keys.key?(val)

          @values << val
          @keys[val] = true
        end
      end

      module BasicSubrequests
        extend Restforce::Resources::SubrequestBuilder

        # subrequest.create(sobject_name, reference_id, body = {}, opts = {})
        #
        # sobject_name  - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        # opts          - You can override the api_version
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
                          :sobject_name, :reference_id, :id

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
                          :sobject_name, :reference_id, :id

        # subrequest.update_by_id(sobject_name, reference_id, sobject_id, opts = {})
        #
        # sobject_name  - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        # sobject_id    - A Salesforce Id
        # opts          - this is where you can specify some :http_headers ie:
        #                 { http_headers:
        #                   { "If-Modified-Since" => "Tue, 31 May 2016 18:00:00 GMT" },
        #                 }
        define_subrequest :update,
                          'Restforce::Resources::SObjectRows',
                          :patch,
                          :sobject_name, :reference_id, :id

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

        #
        #   subrequest.headers_by(sobject_name, reference_id, field_value, field_name)
        #
        # Returns only the headers that are returned by sending a GET request to the
        # sObject Rows by External ID resource. This gives you a chance to see returned
        # header values of the GET request before retrieving the content itself.
        #
        # sobject_name  - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        # field_value   - A Salesforce External Id
        # field_name    - The External Field Name
        # opts          - You can override the api_version

        define_subrequest :headers_by,
                          'Restforce::Resources::SObjectRowsByExternalId',
                          :head,
                          :sobject_name, :reference_id, :field_value, :field_name
      end

      class GraphSubrequests
        extend Restforce::Resources::SubrequestBuilder
        include BasicSubrequests
        attr_reader :options, :requests, :reference_ids

        def initialize(options)
          @options = options
          @requests = []
        end
      end

      class CompositeSubrequests
        extend Restforce::Resources::SubrequestBuilder
        include BasicSubrequests
        attr_reader :options, :requests, :reference_ids

        def initialize(options)
          @options = options
          @requests = []
        end

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

        # subrequest.query(soql, reference_id,
        #                 http_headers: {"Sforce-Query-Options" => 'batchSize=1000'})
        #
        # soql          - The String containing the soql query
        # reference_id  - The reference id to match with the response
        # opts          - You can override the batch size
        #
        #
        # Note: Using a reference_id in a sub request from a Query is done like so
        #
        #   ret1 = client.composite do |sub|
        #     sub.query("select Id from Contact where Email != null limit 10", 'c1')
        #     sub.query("select Email from Contact where Id = '@{c1.records[0].Id}'",
        #               'c2')
        #   end

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

        # subrequest.get_approval_layouts(sobject_name, reference_id)
        # subrequest.describe_approval_layouts(sobject_name, reference_id)
        #
        # sobject       - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        define_generic_subrequest :approval_layouts,
                                  'Restforce::Resources::Base',
                                  [:get, :head],
                                  :sobject_name,
                                  :reference_id do |obj|
          obj.opts[:url] = "/services/data/v#{obj.opts[:api_version]}/sobjects/" \
                           "#{obj.opts[:sobject_name]}/describe/approvalLayouts/"
        end

        # subrequest.get_layout_description(sobject_name, reference_id)
        # subrequest.describe_layout_description(sobject_name, reference_id)
        #
        # sobject       - The String name of the sobject.
        # reference_id  - The reference id to match with the response
        define_generic_subrequest :layout_description,
                                  'Restforce::Resources::Base',
                                  [:get, :head],
                                  :sobject_name,
                                  :reference_id do |obj|
          obj.opts[:url] = "/services/data/v#{obj.opts[:api_version]}/sobjects/" \
                           "#{obj.opts[:sobject_name]}/describe/layouts/"
        end

        alias update_by_id update
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
