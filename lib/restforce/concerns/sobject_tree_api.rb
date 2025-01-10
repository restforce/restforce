# frozen_string_literal: true

require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module SobjectTreeAPI
      extend Restforce::Concerns::Verbs
      define_verbs :post

      attr_reader :options

      def initialize(options)
        @options = options
      end

      def sobjectTree(sobject, sobject_tree_payload)
        path = sobject_tree_api_path(sobject)
        properties = sync_records(sobject, sobject_tree_payload)
        response = api_post(path, properties)

        results = response.body
        # Check if there are errors
        has_errors = results['hasErrors']

        if has_errors
          results['results'].each do |result|
            result['errors'].each do |error|
              statusCode = error['statusCode']
              message = error['message']
              fields = error['fields']

              # Handle the error as needed
              # For example, raise an exception or log the error
              raise SobjectTreeAPIError.new(statusCode, message, fields)
            end
          end
        end

        results
      end

      def sobjectTree!
        sobjectTree
      end

      def sync_records(sobject, sobject_tree_payload)
        headers = { "Content-Type" => "application/json" }

        {
          url: sobject_tree_api_path(sobject),
          payload: sobject_tree_payload,
          headers: headers
        }.to_json
      end

      private

      def sobject_tree_api_path(sobject)
        "/services/data/v#{options[:api_version]}/composite/tree/#{sobject}"
      end
    end
  end
end
