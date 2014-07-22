require 'spec_helper'

describe Restforce::Middleware::Mashify do
  let(:env) { { :body => JSON.parse(fixture('sobject/query_success_response')) } }
  subject(:middleware) {
    described_class.new(lambda {|env|
      Faraday::Response.new(env)
    }, client, options)
  }

  describe '.call' do
    subject { lambda { middleware.call(env) } }

    it { should change { env[:body] }.to(kind_of(Restforce::Collection)) }
  end
end
