# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::CompositeGraphAPI::GraphsBuilder do
  subject do
    Restforce::Concerns::CompositeGraphAPI::GraphsBuilder.new(api_version: '50.0')
  end

  describe "#graph_count" do
    it "should be 0 when no graphs are presents" do
      expect(subject.graphs_count).to be_zero
    end

    it "should be 1 when 1 graph is presents" do
      subject.graph('foo') { |builder| builder }
      subject.graph('foo2') { |builder| builder }
      expect(subject.graphs_count).to be(2)
    end
  end

  describe "#node_count" do
    it "should be 0 when no graphs are presents" do
      expect(subject.node_count).to be_zero
    end

    it "should be 0 when no nodes are presents" do
      subject.graph('foo') { |builder| builder }
      expect(subject.node_count).to be_zero
    end

    it "should be 1 when 1 graph is presents" do
      subject.graph('foo2') do |subrequests|
        subrequests.find('Foo', 'ref1', 'bar')
      end
      expect(subject.node_count).to be(1)
    end
  end

  describe "#graph" do
    it "should name the graph" do
      subject.graph('foo') { |builder| builder }
      expect(subject.graphs).to eq([{ graphId: 'foo', compositeRequest: [] }])
    end

    it "should yield a Restforce::Concerns::SubRequests::GraphSubrequests" do
      clazz = Restforce::Concerns::SubRequests::GraphSubrequests
      subject.graph('foo') do |subrequests|
        expect(subrequests).to be_kind_of(clazz)
      end
    end

    it "should raise an ArgumentError if reusing a graph name" do
      subject.graph('foo') { |builder| builder }
      expect do
        subject.graph('foo') { |builder| builder }
      end.to raise_error(ArgumentError)
    end
  end
end
