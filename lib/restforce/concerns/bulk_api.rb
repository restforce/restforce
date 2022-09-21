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

      extend Restforce::Concerns::Verbs

      define_verbs :post, :put, :patch

      def bulk_upsert(sobject_name, external_key, data)
        response_on_create = api_post(
          'jobs/ingest',
          UpsertJob.create_params(sobject_name, external_key).to_json
        )

        job = UpsertJob.new(response_on_create.body)

        api_put(
          "#{job.api_path}/batches",
          job.prepare_upload_content(data)
        )

        api_patch(
          job.api_path,
          job.patch_state_params(JobState::UPLOAD_COMPLETED).to_json
        )

        job
      end

      class UpsertJob
        attr_reader :id, :object_name, :external_key

        def self.create_params(sobject_name, external_key)
          {
            object: sobject_name,
            contentType: 'CSV',
            operation: 'upsert',
            lineEnding: 'LF',
            externalIdFieldName: external_key
          }
        end

        def initialize(response_body)
          @id = response_body['id']
          @object_name = response_body['object']
          @external_key = response_body['externalIdField']
        end

        def api_path
          "jobs/#{id}"
        end

        def patch_state_params(state)
          { 'state' => state }
        end

        def prepare_upload_content(_data)
          # TODO: turn it into a CSV
          []
        end
      end
    end
  end
end
