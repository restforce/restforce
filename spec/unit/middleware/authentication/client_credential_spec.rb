# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::Authentication::ClientCredential do
  let(:options) do
    { host: 'login.salesforce.com',
      client_id: 'client_id',
      client_secret: 'client_secret',
      adapter: :net_http }
  end

  it_behaves_like 'authentication middleware' do
    let(:success_request) do
      stub_login_request(
        body: "grant_type=client_credentials&" \
              "client_id=client_id&client_secret=client_secret"
      ).to_return(
        status: 200,
        body: fixture(:auth_success_response),
        headers: { "Content-Type" => "application/json" }
      )
    end

    let(:fail_request) do
      stub_login_request(
        body: "grant_type=client_credentials&" \
              "client_id=client_id&client_secret=client_secret"
      ).to_return(
        status: 400,
        body: fixture(:refresh_error_response),
        headers: { "Content-Type" => "application/json" }
      )
    end
  end
end
