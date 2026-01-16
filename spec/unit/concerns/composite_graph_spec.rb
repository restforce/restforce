# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::CompositeGraphAPI::CompositeGraph do
  subject { Restforce::Concerns::CompositeGraphAPI::CompositeGraph }
  let(:composite) { subject.new(api_version: 50) }
  describe "#new" do
    it "should raise an APIVersionError when api_version is missing" do
      expect { subject.new }.to raise_error(Restforce::APIVersionError)
    end

    it "should raise an APIVersionError when version is not met" do
      expect { subject.new(api_version: 20) }.to raise_error(Restforce::APIVersionError)
    end

    it "should NOT raise an APIVersionError when version is not met" do
      expect { valid_subject }.not_to raise_error(Restforce::APIVersionError)
    end
  end

  describe "#validate!" do
    it "should not raise ArgumentError when everything is fine" do
      expect do
        composite.validate!
      end.not_to raise_error
    end

    it "should raise an ArgumentError when there are too many graphs" do
      composite.yield_builder do |builder|
        subject::MAX_GRAPH_COUNT.times do |i|
          builder.graph("name#{i}")
        end
      end
      composite.validate!
      expect do
        composite.yield_builder do |builder|
          builder.graph("name#{subject::MAX_GRAPH_COUNT + 1}")
        end
        composite.validate!
      end.to raise_error(ArgumentError)
    end

    it "should raise an ArgumentError when there are too many nodes" do
      expect do
        composite.yield_builder do |builder|
          builder.graph("name") do |subrequest|
            (subject::MAX_NODE_COUNT + 1).times do |i|
              subrequest.find('Account', "ref#{i}", "id#{i}")
            end
          end
        end
        composite.validate!
      end.to raise_error(ArgumentError)
    end
  end
  describe "#yield_builder" do
    it "should yield a Restforce::Concerns::CompositeGraphAPI::GraphsBuilder" do
      composite.yield_builder do |builder|
        expect(builder).to be_kind_of(Restforce::Concerns::
            CompositeGraphAPI::GraphsBuilder)
      end
    end
  end

  describe "#to_hash" do
    it "should call graphs on the builder" do
      expect(composite.builder).to receive(:graphs).at_least(:once)
      composite.to_hash
    end

    it "should return a hash" do
      expect(composite.to_hash).to eq({ graphs: [] })
    end
  end

  describe "#to_json" do
    it "should return a json hash" do
      expect(composite.to_json).to eq("{\"graphs\":[]}")
    end
  end
end
