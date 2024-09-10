# frozen_string_literal: true

require 'spec_helper'
require 'hashie/mash'

describe Restforce::Concerns::CompositeGraphAPI do
  let(:endpoint) { 'composite/graph' }
  let(:expected_output) do
    {
      graphs: [{ graphId: "g1",
                 compositeRequest: [{ method: "GET",
                                      url: "/services/data/v50.0/sobjects/Contact/xxx",
                                      referenceId: "c1" }] }]

    }
  end
  let(:response_hash) do
    {
      graphs: [
        {
          graphId: 'g1',
          graphResponse: {
            compositeResponse: []
          },
          isSuccessful: true
        }
      ]
    }
  end

  before do
    client.should_receive(:options).and_return(api_version: 50.0)
  end

  it "should populate has_error if any of the graphs have failed" do
    response_hash[:graphs].first['isSuccessful'] = false
    client.
      should_receive(:api_post).
      with(endpoint, expected_output.to_json).
      and_return(Hashie::Mash.new(body: response_hash))

    result = client.composite_graph do |builder|
      builder.graph('g1') do |subrequest|
        subrequest.find('Contact', 'c1', 'xxx')
      end
    end
    expect(result.has_errors).to be_truthy
  end

  it "should NOT populate has_error if NONE of the graphs have failed" do
    client.
      should_receive(:api_post).
      with(endpoint, expected_output.to_json).
      and_return(Hashie::Mash.new(body: response_hash))

    result = client.composite_graph do |builder|
      builder.graph('g1') do |subrequest|
        subrequest.find('Contact', 'c1', 'xxx')
      end
    end
    expect(result.has_errors).to be_falsey
  end

  context "in debug mode" do
    it "should return a hash" do
      debug_output = client.composite_graph(debug: true) do |builder|
        builder.graph('g1') do |subrequest|
          subrequest.find('Contact', 'c1', 'xxx')
        end
      end

      expect(debug_output).to eq(expected_output)
    end
  end
end
