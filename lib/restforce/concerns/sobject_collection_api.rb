# frozen_string_literal: true

require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module SObjectCollectionAPI
      extend Restforce::Concerns::Verbs

      define_verbs :post, :patch, :delete

      def collection_get(sobject_name, ids, fields)
        raise ArgumentError, "ids are required" if Array(ids).empty?
        raise ArgumentError, "fields are required" if Array(fields).empty?

        api_get("composite/sobjects/#{sobject_name}",
                ids: ids.join(','),
                fields: fields.join(',')).body
      end

      def collection_delete(ids, opts = {})
        all_or_none = opts.fetch(:all_or_none, false)
        raise ArgumentError, "ids are required" if Array(ids).empty?

        results = api_delete("composite/sobjects",
                             ids: ids.join(','),
                             allOrNone: all_or_none).body
        CollectionResponse.new(results, all_or_none: all_or_none).response
        results
      end

      def collection_delete!(*ids)
        collection_delete(ids.flatten, all_or_none: true)
      end

      def collection_create(opts = {})
        all_or_none = opts.delete(:all_or_none) || false
        builder = RecordsBuilder.new
        yield(builder)
        return builder.records if opts[:debug]

        if builder.records.empty?
          raise ArgumentError, "There are no records to be created"
        end

        results = api_post('composite/sobjects',
                           {
                             allOrNone: all_or_none,
                             records: builder.records
                           }).body
        CollectionResponse.new(results, all_or_none: all_or_none).response
      end

      def collection_create!(opts = {}, &block)
        collection_create(opts.merge(all_or_none: true), &block)
      end

      def collection_update(opts = {})
        all_or_none = opts.delete(:all_or_none) || false
        builder = RecordsBuilder.new
        yield(builder)
        return builder.records if opts[:dry_run]

        if builder.records.empty?
          raise ArgumentError, "There are no records to be created"
        end

        results = api_patch('composite/sobjects',
                            {
                              allOrNone: all_or_none,
                              records: builder.records
                            }).body
        CollectionResponse.new(results, all_or_none: all_or_none).response
      end

      def collection_update!(opts = {}, &block)
        collection_update(opts.merge(all_or_none: true), &block)
      end

      def collection_upsert(sobject_type, field_name, opts = {})
        all_or_none = opts.fetch(:all_or_none, false)
        builder = RecordsBuilder.new(field_name.to_sym)
        yield(builder)
        return builder.records if opts[:debug]

        if builder.records.empty?
          raise ArgumentError, "There are no records to be created"
        end

        results = api_patch("composite/sobjects/#{sobject_type}/#{field_name}",
                            {
                              allOrNone: all_or_none,
                              records: builder.records
                            }).body
        CollectionResponse.new(results, all_or_none: all_or_none).response
      end

      def collection_upsert!(sobject_type, field_name, opts = {}, &block)
        collection_upsert(sobject_type, field_name, opts.merge(all_or_none: true), &block)
      end

      class CollectionResponse
        attr_accessor :results, :all_or_none

        def initialize(results, all_or_none: false)
          @results = results
          @all_or_none = all_or_none
        end

        def response
          has_errors = results.any? { |result| !result.success }
          if all_or_none && has_errors
            last_error_index = results.rindex do |result|
              !result.success && !result.errors.empty? &&
                result.errors.last.statusCode != 'ALL_OR_NONE_OPERATION_ROLLED_BACK '
            end
            last_error = results[last_error_index]
            raise ::Restforce::ResponseError.new(last_error.errors.last.message, results)
          end
          results
        end
      end

      class RecordsBuilder
        attr_accessor :records, :required_field

        def initialize(required_field = nil)
          @records = []
          @required_field = required_field
        end

        def add(sobject_type, opts = {})
          if required_field_missing?(opts)
            raise ArgumentError, "Missing required field #{required_field}"
          end

          records << {
            attributes: { type: sobject_type }
          }.merge(opts)
        end

        def required_field_missing?(opts = {})
          required_field &&
            opts.keys.find { |k, _| k.to_s.casecmp(required_field.to_s).zero? }.nil?
        end
      end
    end
  end
end
