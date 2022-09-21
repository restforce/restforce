# frozen_string_literal: true

require 'restforce/concerns/verbs'

module Restforce
  module Concerns
    module BulkAPI
      extend Restforce::Concerns::Verbs

      define_verbs :post

      def bulk_upsert(sobject_name, external_key, _data)
        create_job_response = api_post(
          UpsertJob.api_path,
          UpsertJob.create_params(sobject_name, external_key).to_json
        )

        job = UpsertJob.new(create_job_response.body)
        job
      end

      class UpsertJob
        attr_reader :id, :object_name, :external_key

        def self.api_path
          'jobs/ingest'
        end

        def self.create_params(sobject_name, external_key)
          {
            object: sobject_name,
            contentType: 'CSV',
            operation: 'upsert',
            lineEnding: 'LF',
            externalIdFieldName: external_key
          }
        end

        def initialize(create_job_response_body)
          @id = create_job_response_body['id']
        end
      end
    end
  end
end
