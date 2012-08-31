require 'spec_helper'

describe Restforce::Middleware::Authorization do
  let(:app)        { double('app')            }
  let(:env)        { { request_headers: {} }  }
  let(:options)    { { oauth_token: 'token' } }
  let(:middleware) { described_class.new app, options }

  before do
    app.should_receive(:call)
  end

  it 'adds the oauth token to the headers' do
    middleware.call(env)
    env[:request_headers]['Authorization'].should eq 'OAuth token'
  end
end
