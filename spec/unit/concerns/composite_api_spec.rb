# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::CompositeAPI do
  let(:endpoint) { 'composite' }

  before do
    client.should_receive(:options).and_return(api_version: 38.0)
  end

  shared_examples_for 'composite requests' do
    it '#create' do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'POST',
            url: '/services/data/v38.0/sobjects/Object',
            body: { name: 'test' },
            referenceId: 'create_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.create('Object', 'create_ref', name: 'test')
      end
    end

    it '#update' do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'PATCH',
            url: '/services/data/v38.0/sobjects/Object/123',
            body: { name: 'test' },
            referenceId: 'update_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.update('Object', 'update_ref', id: '123', name: 'test')
      end
    end

    it '#destroy' do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'DELETE',
            url: '/services/data/v38.0/sobjects/Object/123',
            referenceId: 'destroy_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.destroy('Object', 'destroy_ref', '123')
      end
    end

    it '#upsert' do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'PATCH',
            url: '/services/data/v38.0/sobjects/Object/extIdField__c/456',
            body: { name: 'test' },
            referenceId: 'upsert_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.upsert('Object', 'upsert_ref', 'extIdField__c',
                           extIdField__c: '456', name: 'test')
      end
    end

    it 'multiple subrequests' do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'POST',
            url: '/services/data/v38.0/sobjects/Object',
            body: { name: 'test' },
            referenceId: 'create_ref'
          },
          {
            method: 'PATCH',
            url: '/services/data/v38.0/sobjects/Object/123',
            body: { name: 'test' },
            referenceId: 'update_ref'
          },
          {
            method: 'DELETE',
            url: '/services/data/v38.0/sobjects/Object/123',
            referenceId: 'destroy_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.create('Object', 'create_ref', name: 'test')
        subrequests.update('Object', 'update_ref', id: '123', name: 'test')
        subrequests.destroy('Object', 'destroy_ref', '123')
      end
    end

    it 'fails if more than 25 requests' do
      expect do
        client.send(method) do |subrequests|
          26.times do |i|
            subrequests.upsert('Object', "upsert_ref_#{i}", 'extIdField__c',
                               extIdField__c: '456', name: 'test')
          end
        end
      end.to raise_error(ArgumentError)
    end
  end

  describe '#composite' do
    let(:method) { :composite }
    let(:all_or_none) { false }
    let(:response) { double('Faraday::Response', body: { 'compositeResponse' => [] }) }
    it_behaves_like 'composite requests'
  end

  describe '#composite!' do
    let(:method) { :composite! }
    let(:all_or_none) { true }
    let(:response) do
      double('Faraday::Response', body: { 'compositeResponse' => [] })
    end
    it_behaves_like 'composite requests'
  end
end
