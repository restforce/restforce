# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::Mashify do
  let(:env) { { body: JSON.parse(fixture('sobject/query_success_response')) } }
  subject(:middleware) {
    described_class.new(lambda { |env|
      Faraday::Response.new(env)
    }, client, options)
  }

  describe '.call' do
    it "should change the body to a Restforce::Collection" do
      expect(middleware.call(env).body).to be_kind_of(Restforce::Collection)
    end
  end
end
