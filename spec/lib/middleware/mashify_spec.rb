require 'spec_helper'

describe Restforce::Middleware::Mashify do
  let(:app)        { double('app')            }
  let(:env)        { { :body => JSON.parse(fixture('sobject/query_success_response')) } }
  let(:options)    { { } }
  let(:middleware) { described_class.new app, nil, options }

  before do
    app.should_receive(:call)
    middleware.call(env)
  end

  it 'converts the response body into a restforce collection' do
    env[:body].should be_a Restforce::Collection
  end
end
