# frozen_string_literal: true

require 'spec_helper'
describe Restforce::Middleware::Authentication::JWTBearer do
  let(:jwt_key) { File.read('spec/fixtures/test_private.key') }

  let(:options) do
    { host: 'login.salesforce.com',
      client_id: 'client_id',
      username: 'foo',
      jwt_key: jwt_key,
      instance_url: 'https://na1.salesforce.com',
      adapter: :net_http }
  end

  it_behaves_like 'authentication middleware' do
    let(:success_request) do
      stub_login_request(
        body: "grant_type=grant_type—urn:ietf:params:oauth:grant-type:jwt-bearer&" \
              "assertion=abc1234567890"
      ).to_return(status: 200, body: fixture(:auth_success_response))
    end

    let(:fail_request) do
      stub_login_request(
        body: "grant_type=grant_type—urn:ietf:params:oauth:grant-type:jwt-bearer&" \
              "assertion=abc1234567890"
      ).to_return(status: 400, body: fixture(:refresh_error_response))
    end
  end

  context 'allows jwt_key as string' do
    let(:jwt_key) do
      File.read('spec/fixtures/test_private.key')
    end

    let(:options) do
      { host: 'login.salesforce.com',
        client_id: 'client_id',
        username: 'foo',
        jwt_key: jwt_key,
        instance_url: 'https://na1.salesforce.com',
        adapter: :net_http }
    end

    it_behaves_like 'authentication middleware' do
      let(:success_request) do
        stub_login_request(
          body: "grant_type=grant_type—urn:ietf:params:oauth:grant-type:jwt-bearer&" \
                "assertion=abc1234567890"
        ).to_return(status: 200, body: fixture(:auth_success_response))
      end

      let(:fail_request) do
        stub_login_request(
          body: "grant_type=grant_type—urn:ietf:params:oauth:grant-type:jwt-bearer&" \
                "assertion=abc1234567890"
        ).to_return(status: 400, body: fixture(:refresh_error_response))
      end
    end
  end
end
