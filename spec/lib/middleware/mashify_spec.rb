require 'spec_helper'

describe Restforce::Middleware::Mashify do
  let(:app)        { double('app')            }
  let(:options)    { { } }
  let(:middleware) { described_class.new app, nil, options }

  before do
    app.should_receive(:call)
    middleware.call(env)
  end

  context 'when the body contains a records key' do
    let(:env) { { :body => JSON.parse(fixture('sobject/query_success_response')) } }

    it 'converts the response body into a restforce collection' do
      expect(env[:body]).to be_a Restforce::Collection
    end
  end

  context 'when the body does not contain records' do
    let(:env) { { :body => { 'foo' => 'bar' } } }

    it 'does not touch the body' do
      expect(env[:body].foo).to eq 'bar'
    end
  end
end
