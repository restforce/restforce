# frozen_string_literal: true

require 'spec_helper'
require 'hashie/mash'

describe Restforce::Concerns::SObjectCollectionAPI do
  let(:endpoint) { 'composite/sobjects' }

  before do
    # client.should_receive(:options).and_return(api_version: 38.0)
  end

  describe "#collection_get" do
    let(:endpoint) { 'composite/sobjects/Contact' }
    let(:contacts_response) do
      [
        { "attributes" => { "type" => "Contact",
                            "url" => "/services/data/v57.0/sobjects/Contact/1" },
          "Email" => "test1@example.com", "Id" => "1", "First" => 'Mike' },
        { "attributes" => { "type" => "Contact",
                            "url" => "/services/data/v57.0/sobjects/Contact/2" },
          "Email" => "test2@example.com", "Id" => "2", "First" => 'John' }
      ]
    end

    it "requires ids to be passed" do
      expect do
        client.collection_get("Contact", nil, %w[Name])
      end.to raise_error(ArgumentError)
    end

    it "requires ids to be passed" do
      expect do
        client.collection_get("Contact", [1], [])
      end.to raise_error(ArgumentError)
    end

    it "returns a response" do
      client.
        should_receive(:api_get).
        with(endpoint, ids: '1,2', fields: "First,Email").
        and_return(Hashie::Mash.new(body: contacts_response))

      result = client.collection_get("Contact", [1, 2], %w[First Email])
      expect(result.first['First']).to eq('Mike')
      expect(result.last['First']).to eq('John')
    end
  end

  let(:successful_response) do
    [{ "id" => "001RM000003oLrHYAU", "success" => true, "errors" => [] },
     { "id" => "001RM000003oLraYAE", "success" => true, "errors" => [] }]
  end
  let(:unsuccessful_response) do
    [{ "id" => "001RM000003oLrfYAE", "success" => true, "errors" => [] },
     { "success" => false,
       "errors" => [{ "statusCode" => "MALFORMED_ID",
                      "message" => "malformed id 001RM000003oLrB000", "fields" => [] }] }]
  end
  let(:rolledback_response) do
    [{ "id" => "001RM000003oLruYAE", "success" => false,
       "errors" => [{ "statusCode" => "ALL_OR_NONE_OPERATION_ROLLED_BACK",
                      "message" => "Record rolled back because not all records were " \
                                   "valid and the request was using AllOrNone header",
                      "fields" => [] }] },
     { "success" => false,
       "errors" => [{ "statusCode" => "MALFORMED_ID",
                      "message" => "malformed id 001RM000003oLrB000", "fields" => [] }] }]
  end

  describe "#collection_delete" do
    it "should raise an ArgumentError when no ids are passed" do
      expect do
        client.collection_delete(nil)
      end.to raise_error(ArgumentError)
    end

    it "should NOT raise an ArgumentError when ids are passed" do
      expect do
        client.collection_delete([1, 2, 3])
      end.not_to raise_error(ArgumentError)
    end

    it "should return the correct size when successfull" do
      client.
        should_receive(:api_delete).
        with(endpoint, ids: '1,2', allOrNone: false).
        and_return(Hashie::Mash.new(body: successful_response))

      expect(client.collection_delete([1, 2]).size).to be(2)
    end
  end

  describe "#collection_delete!" do
    it "should delegate to collection_delete with all_or_none = true" do
      client.should_receive(:collection_delete).with([1, 2], all_or_none: true)
      client.collection_delete!([1, 2])
    end
  end

  shared_examples_for "a collection create/update operation" do |method,
                                                                 api_method,
                                                                 *args|
    def collection_client_expectation(all_or_none, response, api_method = :api_post)
      client.
        should_receive(api_method).
        with(endpoint,
             allOrNone: all_or_none,
             records: [{
               attributes: { type: "Account" }
             }.merge(record_attributes)]).and_return(Hashie::Mash.new(body: response))
    end

    it "should raise en arror when there are no records" do
      expect do
        client.send(method, *[args, { all_or_none: false }].flatten.compact) do |builder|
          builder
        end
      end.to raise_error(ArgumentError)
    end

    [true, false].each do |all_or_none_value|
      it "should take an all_or_none: #{all_or_none_value} parameter and pass it along" do
        collection_client_expectation(all_or_none_value, successful_response, api_method)
        client.send(method,
                    *[args,
                      { all_or_none: all_or_none_value }].flatten.compact) do |records|
          records.add('Account', record_attributes)
        end
      end
    end

    describe "##{method}!" do
      it "should delegate to #{method} with all_or_none = true" do
        client.should_receive(method).with(*[args, { all_or_none: true }].flatten.compact)
        client.send("#{method}!", *args)
      end

      it "should delegate to #{method} the proper block" do
        collection_client_expectation(true, successful_response, api_method)
        client.send("#{method}!", *args) do |builder|
          builder.add('Account', record_attributes)
        end
      end
    end
  end

  describe "#collection_create" do
    it_behaves_like "a collection create/update operation",
                    :collection_create, :api_post do
      let(:record_attributes) do
        {
          Name: "example",
          BillingCity: "San Francisco"
        }
      end
    end
  end

  describe "#collection_update" do
    it_behaves_like "a collection create/update operation",
                    :collection_update, :api_patch do
      let(:record_attributes) do
        {
          id: '123',
          Name: "example",
          BillingCity: "San Francisco"
        }
      end
    end
  end

  describe "#collection_upsert" do
    it_behaves_like "a collection create/update operation",
                    :collection_upsert, :api_patch, "Account", 'MyExtId__c' do
      let(:endpoint) { "composite/sobjects/Account/MyExtId__c" }
      let(:record_attributes) do
        {
          MyExtId__c: 'asdf',
          id: '123',
          Name: "example",
          BillingCity: "San Francisco"
        }
      end
    end

    it "should raise an error if the external_id is not present in the record" do
      expect do
        client.collection_upsert("Account", 'MyExtId__c') do |records|
          records.add(record_attributes)
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe Restforce::Concerns::SObjectCollectionAPI::RecordsBuilder do
    subject { Restforce::Concerns::SObjectCollectionAPI::RecordsBuilder }
    describe "#add" do
      it "should raise an error if a required field is NOT passed in" do
        builder = subject.new(:Foo)
        expect do
          builder.add('Account', id: '123')
        end.to raise_error
      end

      it "should NOT raise an error if a required field is passed in" do
        builder = subject.new(:Foo)
        expect do
          builder.add('Account', 'Foo' => '123')
        end.not_to raise_error
      end

      it "should add to the records" do
        builder = subject.new(:Foo)
        builder.add('Account', 'Foo' => '123', "bar" => 'baz')
        expect(builder.records).to eq([{
                                        attributes: { type: "Account" },
                                        'Foo' => '123',
                                        'bar' => 'baz'
                                      }])
      end
    end
  end

  describe "CollectionResponse" do
    subject { Restforce::Concerns::SObjectCollectionAPI::CollectionResponse }
    context "a successfull response" do
      [true, false].each do |all_or_none|
        it "returns a response when is all_or_none = #{all_or_none}" do
          result = Hashie::Mash.new(body: successful_response).body
          expect(subject.new(result, all_or_none: all_or_none).response).to eq(result)
        end
      end
    end

    context "an unsuccessful response" do
      it "returns a response when is all_or_none = false" do
        result = Hashie::Mash.new(body: unsuccessful_response).body
        expect(subject.new(result, all_or_none: false).response).to eq(result)
      end
    end

    context "a rollback response" do
      it "returns a response when is all_or_none = true" do
        result = Hashie::Mash.new(body: rolledback_response).body
        expect do
          subject.new(result, all_or_none: true).response
        end.to raise_error(Restforce::ResponseError)
      end

      it "raises an error with an accessible response" do
        result = Hashie::Mash.new(body: rolledback_response).body
        begin
          subject.new(result, all_or_none: true).response
        rescue StandardError => e
          expect(e.message).to eq("malformed id 001RM000003oLrB000")
          expect(e.response).to be_kind_of(Hashie::Array)
        end
      end
    end
  end
end
