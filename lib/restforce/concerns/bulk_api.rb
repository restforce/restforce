# frozen_string_literal: true

require 'restforce/concerns/verbs'
require 'csv'

module Restforce
  module Concerns
    module BulkAPI
      module JobState
        OPEN = 'Open'
        UPLOAD_COMPLETED = 'UploadComplete'
        ABORTED = 'Aborted'
        JOB_COMPLETED = 'JobComplete'
        FAILED = 'Failed'
      end

      def bulk_upsert(sobject_name, external_key, _data)
        UpsertJob.create!(sobject_name, external_key, connection: connection,
                                                      options: options)
      end

      class UpsertJob
        attr_reader :id, :sobject_name, :external_key

        private_class_method :new

        def initialize(_sobject_name, _external_key, connection:, options:)
          @connection = connection
          @options = options
        end

        def self.create!(sobject_name, external_key, connection:, options:)
          job = new(sobject_name, external_key, connection: connection, options: options)

          puts "path #{job.bulk_api_path}"
          response = connection.post(job.bulk_api_path) do |req|
            req.headers['Content-Type'] = 'application/json'
            req.body = {
              object: sobject_name,
              contentType: 'CSV',
              operation: 'upsert',
              lineEnding: 'LF',
              externalIdFieldName: external_key
            }.to_json
          end

          job.send(:id=, response.body['id'])
          job
        end

        def bulk_api_path(path = '')
          "/services/data/v#{options[:api_version]}/jobs/ingest/#{path}"
        end

        private

        attr_writer :id

        attr_reader :connection, :options
      end
    end
  end
end
