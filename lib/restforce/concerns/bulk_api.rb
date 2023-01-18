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

      def bulk_upsert(sobject_name, external_key, data)
        job = UpsertJob.create!(sobject_name, external_key, connection: connection,
                                                            options: options)
        job.upload_csv(data)
        job.patch_state(JobState::UPLOAD_COMPLETED)
        job
      end

      def retrieve_ingest_job(job_id)
        UpsertJob.retrieve(job_id, connection: connection, options: options)
      end

      class UpsertJob
        attr_reader :id, :sobject_name, :external_key

        private_class_method :new

        def initialize(sobject_name, external_key, connection:, options:)
          @sobject_name = sobject_name
          @external_key = external_key
          @connection = connection
          @options = options
        end

        def self.create!(sobject_name, external_key, connection:, options:)
          job = new(sobject_name, external_key, connection: connection, options: options)

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

        def self.retrieve(job_id, connection:, options:)
          response = connection.
                     get("/services/data/v#{options[:api_version]}/jobs/ingest/#{job_id}")
          body = response.body

          job = new(body['object'], body['externalIdFieldName'], connection: connection,
                                                                 options: options)
          job.send(:id=, job_id)
          job
        rescue Restforce::NotFoundError
          raise BulkAPIError, "job with id #{job_id} cannot be found."
        end

        def bulk_api_path(path = '')
          "/services/data/v#{options[:api_version]}/jobs/ingest/#{path}"
        end

        def job_api_path(path = '')
          bulk_api_path("#{id}/#{path}")
        end

        def upload_csv(data)
          path = job_api_path('batches')

          connection.put(path) do |req|
            req.headers['Content-Type'] = 'text/csv'
            req.headers['Accept'] = 'application/json'
            req.body = generate_csv(data)
          end
        end

        def patch_state(state)
          patch({ 'state' => state })
        end

        def inspect
          "BulkUpsertJob(id: #{id}, object: '#{sobject_name}', \
            externalIdFieldName:'#{external_key}')"
        end

        private

        attr_reader :connection, :options

        attr_writer :id

        def patch(payload)
          connection.patch(job_api_path, payload.to_json)
        end

        def generate_csv(data)
          CSV.generate do |csv|
            data.each do |row|
              csv << row
            end
          end
        end
      end
    end
  end
end
