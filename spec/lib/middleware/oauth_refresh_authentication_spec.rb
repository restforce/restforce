require 'spec_helper'

describe Restforce::Middleware::OAuthRefreshAuthentication do
  let(:app)        { double('app')            }
  let(:env)        { { }  }
  let(:middleware) { described_class.new app, options }
  let(:options) do
    { host: 'login.salesforce.com',
      refresh_token: 'refresh_token',
      client_id: 'client_id',
      client_secret: 'client_secret' }
  end

  before do
    request
  end

  after do
    request.should have_been_requested
  end

  describe '.authenticate!' do
    context 'when successful' do
      let(:request) do
        stub_request(:post, "https://login.salesforce.com/services/oauth2/token").
          with(:body => "grant_type=refresh_token&refresh_token=refresh_token&" \
          "client_id=client_id&client_secret=client_secret").
          to_return(:status => 200, :body => fixture(:auth_success_response))
      end

      before do
        middleware.authenticate!
      end

      describe '@options' do
        subject { options }

        its([:instance_url]) { should eq 'https://na1.salesforce.com' }
        its([:oauth_token])  { should eq '00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW19ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs' }
      end
    end

    context 'when unsuccessful' do
      let(:request) do
        stub_request(:post, "https://login.salesforce.com/services/oauth2/token").
          with(:body => "grant_type=refresh_token&refresh_token=refresh_token&" \
          "client_id=client_id&client_secret=client_secret").
          to_return(:status => 400, :body => fixture(:auth_success_response))
      end

      it 'raises an exception' do
        expect {
          middleware.authenticate!
        }.to raise_error Restforce::AuthenticationError
      end
    end
  end
end
