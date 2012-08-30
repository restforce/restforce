require 'spec_helper'

describe Restforce::Middleware::Authentication do
  include_context 'basic client'
  include_context 'authentication middleware'

  let(:authentication_request) { oauth_refresh_authentication_request }

  describe 'authentication' do
    context 'oauth token and refresh token are set' do
      let(:expired_token)  { 'expired_token' }
      let(:client_options) { oauth_refresh_options.merge(:oauth_token => expired_token) }

      describe 'the client options' do
        subject { client.instance_variable_get :@options }

        its([:instance_url])  { should eq instance_url  }
        its([:oauth_token])   { should eq oauth_token   }
        its([:refresh_token]) { should eq refresh_token }
      end
    end
  end
end
