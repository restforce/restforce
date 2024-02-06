# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::CompositeAPI do
  let(:endpoint) { 'composite' }

  before do
    client.should_receive(:options).and_return(api_version: 38.0)
  end

  shared_examples_for 'composite requests' do
    it "#find by id" do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'GET',
            url: '/services/data/v38.0/sobjects/Object/@{ref.id}',
            referenceId: 'find_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.find('Object', 'find_ref', '@{ref.id}')
      end
    end

    it "#find_by external_id" do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'GET',
            url: '/services/data/v38.0/sobjects/Object/email/test@salesforce',
            referenceId: 'find_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.find_by('Object', 'find_ref', 'test@salesforce', 'email')
      end
    end

    it "#find by id with fields options passed" do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'GET',
            url: '/services/data/v38.0/sobjects/Object/123?fields=first%2Clast%2Cemail',
            referenceId: 'find_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.find('Object', 'find_ref', '123',
                         fields: %w[first last email])
      end
    end

    it "#find by id with http_headers" do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'GET',
            url: '/services/data/v38.0/sobjects/Object/123',
            httpHeaders: { "If-Modified-Since" => "Tue, 31 May 2016 18:00:00 GMT" },
            referenceId: 'find_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.find('Object', 'find_ref', '123',
                         http_headers:
                           { "If-Modified-Since" => "Tue, 31 May 2016 18:00:00 GMT" })
      end
    end

    it "#query" do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'GET',
            url: '/services/data/v38.0/query?q=select+Email+' \
                 'from+Contact+where+id+%3D+%27@{ref.results[0].id}%27',
            referenceId: 'query_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.query("select Email from Contact where id = '@{ref.results[0].id}'",
                          'query_ref')
      end
    end

    it "#query_all" do
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'GET',
            url: '/services/data/v38.0/queryAll?q=select+Email+' \
                 'from+Contact+where+id+%3D+%27@{ref.results[0].id}%27',
            referenceId: 'query_ref'
          }
        ], allOrNone: all_or_none, collateSubrequests: false }.to_json).
        and_return(response)

      client.send(method) do |subrequests|
        subrequests.query_all("select Email from Contact where id = " \
                              "'@{ref.results[0].id}'",
                              'query_ref')
      end
    end

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
            method: 'GET',
            url: '/services/data/v38.0/sobjects/Contact/123',
            referenceId: 'find_ref'
          },
          {
            method: 'GET',
            url: '/services/data/v38.0/query?q=select+Id+' \
                 'from+Contact+where+Email+%3D+%27@{find_ref.Email}%27',
            referenceId: 'query_ref'
          },
          {
            method: 'GET',
            url: '/services/data/v38.0/queryAll?q=select+Id+' \
                 'from+Contact+where+Email+%3D+%27@{find_ref.Email}%27',
            referenceId: 'query_all_ref'
          },
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
        subrequests.find('Contact', 'find_ref', '123')
        subrequests.query("select Id from Contact where Email = '@{find_ref.Email}'",
                          'query_ref')
        subrequests.query_all("select Id from Contact where Email = '@{find_ref.Email}'",
                              'query_all_ref')
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

    it 'has response in CompositeAPIError' do
      response = double('Faraday::Response',
                        body: { 'compositeResponse' =>
                                  [{ 'httpStatusCode' => 400,
                                     'body' => [{ 'errorCode' =>
                                                    'DUPLICATE_VALUE' }] }] })
      client.
        should_receive(:api_post).
        with(endpoint, { compositeRequest: [
          {
            method: 'POST',
            url: '/services/data/v38.0/sobjects/Object',
            body: { name: 'test' },
            referenceId: 'create_ref'
          }
        ], allOrNone: true, collateSubrequests: false }.to_json).
        and_return(response)
      arg = method == :composite ? { all_or_none: true } : {}
      expect do
        client.send(method, **arg) do |subrequests|
          subrequests.create('Object', 'create_ref', name: 'test')
        end
      end.to raise_error(an_instance_of(Restforce::CompositeAPIError).
        and(having_attributes(response: response)))
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
