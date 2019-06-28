# frozen_string_literal: true

require 'spec_helper'

shared_examples_for Restforce::Bulk::Client do
  describe '.create_job' do
    requests 'jobs/ingest', method: :post, fixture: 'bulk/create_job_success_response'
    subject { client.create_job('Account') }
    it { should eq '0123456789ABC' }
  end

  describe '.upload_csv' do
    requests 'jobs/ingest/0123456789/batches', { method: :put, status: 201, fixture: 'bulk/upload_csv_success_response' }
    subject { client.upload_job_data('0123456789', "\"NAME\"\n\"Foo\"\n\"Bar\"") }
    it { should be_true }
  end

  describe '.close_job' do
    requests 'jobs/ingest/0123456789', { method: :patch, fixture: 'bulk/close_job_success_response' }
    subject { client.close_job('0123456789') }
    it { should be_true }
  end

  describe '.check_status' do
    requests 'jobs/ingest/0123456789', fixture: 'bulk/check_status_success_response'
    subject { client.get_job_status('0123456789') }
    it { should eq 'JobComplete' }
  end

  describe '.success_results' do
    requests 'jobs/ingest/0123456789/successfulResults', fixture: 'bulk/success_results_success_response'
    subject { client.get_job_success_results('0123456789') }
    it {
      should match_array [
                    { "sf__Id" => "0012f000007uKgsAAE", "sf__Created" => "true", "Name" => "Foo Bar" },
                    { "sf__Id" => "0012f000007uKgtAAE", "sf__Created" => "true", "Name" => "Bizz Buzz" }
                ]
    }
  end

  describe '.failed_results' do
    requests 'jobs/ingest/0123456789/failedResults', fixture: 'bulk/failed_results_success_response'
    subject { client.get_job_failed_results('0123456789') }
    it {
      should match_array [
                             { "sf__Id" => "0012f000007uKgsAAE", "sf__Error" => "Error Message", "Name" => "Foo Bar" },
                             { "sf__Id" => "0012f000007uKgtAAE", "sf__Error" => "Error Message", "Name" => "Bizz Buzz" }
                         ]
    }
  end
end


describe Restforce::Bulk::Client do
  describe 'with mashify' do
    it_behaves_like Restforce::Bulk::Client
  end

  describe 'without mashify', mashify: false do
    it_behaves_like Restforce::Bulk::Client
  end
end
