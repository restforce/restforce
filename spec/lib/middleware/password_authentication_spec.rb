require 'spec_helper'

describe Restforce::Middleware::PasswordAuthentication do
  let(:app)        { double('app')            }
  let(:env)        { { }  }
  let(:middleware) { described_class.new app, nil, options }

  let(:options) do
    { host: 'login.salesforce.com',
      username: 'foo',
      password: 'bar',
      security_token: 'security_token',
      client_id: 'client_id',
      client_secret: 'client_secret' }
  end

  it_behaves_like 'authentication middleware' do
    let(:success_request) do
      stub_request(:get, "https://login.salesforce.com/services/oauth2" \
        "/authorize?client_id=client_id&client_secret=client_secret" \
        "&grant_type=password&password=barsecurity_token&username=foo").
        to_return(:status => 200, :body => fixture(:auth_success_response))
    end

    let(:fail_request) do
      stub_request(:get, "https://login.salesforce.com/services/oauth2" \
        "/authorize?client_id=client_id&client_secret=client_secret" \
        "&grant_type=password&password=barsecurity_token&username=foo").
        to_return(:status => 400, :body => fixture(:auth_success_response))
    end
  end

  describe '.password' do
    subject { middleware.password }
    it      { should eq 'barsecurity_token' }
  end
end
