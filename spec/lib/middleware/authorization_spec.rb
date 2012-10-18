require 'spec_helper'

describe Restforce::Middleware::Authorization do
  let(:app)        { double('app')            }
  let(:env)        { { :request_headers => {} }  }
  let(:options)    { { :oauth_token => 'token' } }
  let(:middleware) { described_class.new app, nil, options }

  before do
    app.should_receive(:call)
    middleware.call(env)
  end

  it 'adds the oauth token to the headers' do
    env[:request_headers]['Authorization'].should eq 'OAuth token'
  end
end
