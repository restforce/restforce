# frozen_string_literal: true

require 'spec_helper'
require 'csv'

describe Restforce::Concerns::BulkAPI do
  let(:endpoint) { 'jobs/ingest' }

  describe '.bulk_upsert' do
    let(:response_on_create) do
      double('Faraday::Response', body: {
               'id' => 'abc',
               'operation' => 'upsert',
               'object' => 'foo',
               'externalIdFieldName' => 'bar'
             })
    end

    let(:response_on_put) { double('Faraday::Response', body: {}) }
    let(:response_on_patch) { double('Faraday::Response', body: {}) }

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
        and_return(response_on_create)

      allow(client).
        to receive(:api_put).
        with('jobs/abc/batches', []).
        and_return(response_on_put)

      allow(client).
        to receive(:api_patch).
        with('jobs/abc', { 'state' => 'UploadComplete' }.to_json).
        and_return(response_on_put)
    end

    it 'returns the UpsertJob' do
      job = client.bulk_upsert("foo", "bar", [])
      expect(job.id).to eq 'abc'
    end
  end
end
