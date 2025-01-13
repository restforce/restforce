# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Resources::SubrequestBuilder do
  subject do
    Class.new do
      extend Restforce::Resources::SubrequestBuilder
      attr_accessor :reference_ids, :requests

      def options
        { api_version: 50.0 }
      end
    end
  end

  let(:clazz) { 'Restforce::Resources::Base' }

  describe ".define_subrequest" do
    it "should raise an error if one of the paramenter is not named reference_id" do
      subject.define_subrequest(:describe_layout, clazz, :get, :id)
      expect do
        subject.new.describe_layout "ref#1", url: 'url'
      end.to raise_error
    end

    it "should require that one of the parameters to be named reference_id" do
      subject.define_subrequest(:describe_layout, clazz, :get, :reference_id)
      expect do
        subject.new.describe_layout "ref#1", url: 'url'
      end.not_to raise_error
    end

    it "should require for options to bring back an api_version" do
      subject.define_subrequest(:describe_layout, clazz, :get, :reference_id)
      instance = subject.new
      instance.stub(:options).and_return({})
      expect do
        instance.describe_layout "ref#1", url: 'url'
      end.to raise_error
    end

    it "should allow to pass a block to customize stuff" do
      subject.define_subrequest(:describe_layout, clazz, :get, :reference_id) do |obj|
        obj.opts[:url] = "#{obj.opts[:url]}/#{obj.opts[:reference_id]}/embedded"
      end
      instance = subject.new
      instance.describe_layout("ref#1", url: "path_to")
      expect(instance.requests.last[:url]).to eq('path_to/ref#1/embedded')
    end

    describe "attributes" do
      let(:instance) { subject.new }
      before do
        subject.define_subrequest(:describe_layout, clazz, :get, :reference_id)
        instance.describe_layout "ref#1", url: 'url'
      end

      it "should populate the reference_ids set" do
        expect(instance.reference_ids).not_to be_empty
      end

      it "should populate the reference_ids with the correct id" do
        expect(instance.reference_ids.last).to eq('ref#1')
      end

      it "should populate the requests array" do
        expect(instance.requests).not_to be_empty
      end

      it "should populate the requests array" do
        expect(instance.requests.last).to eq({ method: "GET",
                                               referenceId: "ref#1",
                                               url: "url" })
      end
    end
  end

  describe ".define_generic_subrequest" do
    it "should delegate to define_subrequest with a propertly renamed name" do
      expect(subject).to receive(:define_subrequest).with('get_subrequest_method',
                                                          :clazz, :get, :reference_id)
      expect(subject).to receive(:define_subrequest).with('describe_subrequest_method',
                                                          :clazz, :head, :reference_id)
      subject.define_generic_subrequest(:subrequest_method, :clazz,
                                        %i[get head], :reference_id)
    end
  end

  describe ".rename_http_method_to_friendly_name" do
    {
      get: :get,
      post: :create,
      head: :describe
    }.each do |http_method, expected|
      it "should convert #{http_method} to #{expected}" do
        expect(subject.rename_http_method_to_friendly_name(http_method)).to eq(expected)
      end
    end
    {
      upsert: %i[field_name field_value],
      update: []
    }.each do |expected, params|
      it "should convert :patch to #{expected} when params contains #{params.inspect}" do
        expect(subject.rename_http_method_to_friendly_name(:patch,
                                                           params)).to eq(expected)
      end
    end
  end
end
