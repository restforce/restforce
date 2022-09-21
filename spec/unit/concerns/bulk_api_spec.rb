# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::BulkAPI do
  let(:endpoint) { 'jobs/ingest' }

  describe '.bulk_upsert' do
    let(:response) do
      double('Faraday::Response', body: {
               'id' => 'abc',
               'operation' => 'upsert',
               'object' => 'foo',
               'externalIdFieldName' => 'bar'
             })
    end

    before do
      create_job_payload = {
        object: 'foo',
        contentType: 'CSV',
        operation: 'upsert',
        lineEnding: 'LF',
        externalIdFieldName: 'bar'
      }

      allow(client).
        to receive(:api_post).
        with(endpoint, create_job_payload.to_json).
        and_return(response)
    end

    it 'returns the UpsertJob' do
      job = client.bulk_upsert("foo", "bar", [])
      expect(job.id).to eq 'abc'
    end
  end
end
