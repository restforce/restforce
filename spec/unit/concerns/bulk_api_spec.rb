# frozen_string_literal: true

require 'spec_helper'
require 'csv'

describe Restforce::Concerns::BulkAPI do
  let(:endpoint) { 'jobs/ingest' }
  let(:options) { { api_version: 52.0 } }
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
end
