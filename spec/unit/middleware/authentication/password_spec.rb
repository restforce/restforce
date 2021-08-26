# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::Authentication::Password do
  let(:options) do
    { host: 'login.salesforce.com',
      username: 'foo',
      password: 'bar',
      security_token: 'security_token',
      client_id: 'client_id',
      client_secret: 'client_secret',
      adapter: :net_http }
  end

  it_behaves_like 'authentication middleware' do
    let(:success_request) do
      stub_login_request(
        body: "grant_type=password&client_id=client_id&client_secret=client_secret" \
              "&username=foo&password=barsecurity_token"
      ).to_return(status: 200, body: fixture(:auth_success_response))
    end

    let(:fail_request) do
      stub_login_request(
        body: "grant_type=password&client_id=client_id&client_secret=client_secret" \
              "&username=foo&password=barsecurity_token"
      ).to_return(status: 400, body: fixture(:auth_error_response))
    end
  end

  describe '.password' do
    subject { middleware.password }
    it      { should eq 'barsecurity_token' }
  end
end
