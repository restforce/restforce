# frozen_string_literal: true

require 'spec_helper'
require 'csv'

describe Restforce::Concerns::BulkAPI do
  let(:endpoint) { 'jobs/ingest' }
  let(:api_version) { 52.0 }
  let(:options) { { api_version: api_version } }
  let(:connection) { double('Faraday::Connection', post: nil, patch: nil) }

  before do
    allow(client).to receive(:options).and_return(options)
    allow(client).to receive(:connection).and_return(connection)
  end

  describe '.bulk_upsert' do
    let(:job) { double('UpsertJob', create!: nil, upload_csv: nil, patch_state: nil) }

    before do
      expect(Restforce::Concerns::BulkAPI::UpsertJob).
        to receive(:create!).
        with('foo', 'bar', connection: connection, options: options).
        and_return(job)
    end

    it 'creates a bulk upsert job' do
      client.bulk_upsert('foo', 'bar', [])
    end

    it 'calls #upload_csv on the job' do
      expect(job).to receive(:upload_csv).and_return(nil)
      client.bulk_upsert('foo', 'bar', [])
    end

    it 'sets the job state to UploadComplete' do
      expect(job).to receive(:patch_state).with('UploadComplete').and_return(nil)
      client.bulk_upsert('foo', 'bar', [])
    end
  end

  describe '.retrieve_ingest_job' do
    context 'with an valid job id' do
      let(:job_id) { 'abcd' }
      let(:response) do
        double('Faraday::Response', body: {
                 'id' => job_id,
                 'object' => 'foo',
                 'externalIdFieldName' => 'bar'
               })
      end

      before do
        expect(connection).
          to receive(:get).
          with("/services/data/v#{api_version}/jobs/ingest/#{job_id}").
          and_return(response)
      end

      it 'fetches for job given the id' do
        retrieved_job = client.retrieve_ingest_job(job_id)
        expect(retrieved_job.id).to eq job_id
        expect(retrieved_job.sobject_name).to eq 'foo'
        expect(retrieved_job.external_key).to eq 'bar'
      end
    end

    context 'with an invalid job id' do
      let(:response) { Faraday::Response.new(status: 404) }

      before do
        expect(connection).
          to receive(:get).
          with("/services/data/v#{api_version}/jobs/ingest/invalid_id").
          and_raise(Restforce::NotFoundError.new(nil))
      end

      it 'raises BulkApiError' do
        expect do
          client.retrieve_ingest_job('invalid_id')
        end.to raise_error Restforce::BulkAPIError
      end
    end
  end
end
