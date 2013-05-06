require 'spec_helper'

describe Restforce::Middleware::Mashify do
  let(:env) { { :body => JSON.parse(fixture('sobject/query_success_response')) } }

  describe '.call' do
    subject { lambda { middleware.call(env) } }

    it { should change { env[:body] }.to(kind_of(Restforce::Collection)) }
  end
end
