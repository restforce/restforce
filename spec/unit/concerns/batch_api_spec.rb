# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::BatchAPI do
  let(:endpoint) { 'composite/batch' }

  before do
    client.should_receive(:options).and_return(api_version: 34.0)
  end

  shared_examples_for 'batched requests' do
    it '#create' do
      client.
        should_receive(:api_post).
        with(endpoint, { batchRequests: [
          { method: 'POST', url: 'v34.0/sobjects/Object', richInput: { name: 'test' } }
        ], haltOnError: halt_on_error }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.create('Object', name: 'test')
      end
    end

    it '#update' do
      client.
        should_receive(:api_post).
        with(endpoint, { batchRequests: [
          { method: 'PATCH', url: "v34.0/sobjects/Object/123", richInput: {
            name: 'test'
          } }
        ], haltOnError: halt_on_error }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.update('Object', id: '123', name: 'test')
      end
    end

    it '#destroy' do
      client.
        should_receive(:api_post).
        with(endpoint, { batchRequests: [
          { method: 'DELETE', url: "v34.0/sobjects/Object/123" }
        ], haltOnError: halt_on_error }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.destroy('Object', '123')
      end
    end

    it '#upsert' do
      client.
        should_receive(:api_post).
        with(endpoint, { batchRequests: [
          { method: 'PATCH', url: 'v34.0/sobjects/Object/extIdField__c/456', richInput: {
            name: 'test'
          } }
        ], haltOnError: halt_on_error }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.upsert('Object', 'extIdField__c',
                           extIdField__c: '456', name: 'test')
      end
    end

    it 'multiple subrequests' do
      client.
        should_receive(:api_post).
        with(endpoint, { batchRequests: [
          { method: 'POST', url: 'v34.0/sobjects/Object', richInput: {
            name: 'test'
          } },
          { method: 'PATCH', url: "v34.0/sobjects/Object/123", richInput: {
            name: 'test'
          } },
          { method: 'DELETE', url: "v34.0/sobjects/Object/123" }
        ], haltOnError: halt_on_error }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.create('Object', name: 'test')
        subrequests.update('Object', id: '123', name: 'test')
        subrequests.destroy('Object', '123')
      end
    end
  end

  describe '#batch' do
    let(:method) { :batch }
    let(:halt_on_error) { false }
    let(:response) { double('Faraday::Response', body: { 'results' => [] }) }
    it_behaves_like 'batched requests'
  end

  describe '#batch!' do
    let(:method) { :batch! }
    let(:halt_on_error) { true }
    let(:response) {
      double('Faraday::Response', body: { 'hasErrors' => false, 'results' => [] })
    }
    it_behaves_like 'batched requests'
  end
end
