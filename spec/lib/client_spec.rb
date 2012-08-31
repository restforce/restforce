require 'spec_helper'

describe Restforce::Client do
  include_context 'basic client'
  
  describe '@options' do
    subject { client.instance_variable_get :@options }

    its([:oauth_token])    { should eq oauth_token    }
    its([:refresh_token])  { should eq refresh_token  }
    its([:client_id])      { should eq client_id      }
    its([:client_secret])  { should eq client_secret  }
    its([:username])       { should eq username       }
    its([:password])       { should eq password       }
    its([:security_token]) { should eq security_token }
  end

  describe 'authentication' do
    include_context 'basic client'
    include_context 'authentication middleware'

    describe 'password authentication' do
      let(:authentication_request) { password_authentication_request }

      context 'when a username and password is set' do
        let(:expired_token)  { 'expired_token' }
        let(:client_options) { base_options.merge(:oauth_token => expired_token) }

        describe 'the client options' do
          subject { client.instance_variable_get :@options }

          its([:instance_url]) { should eq instance_url }
          its([:oauth_token])  { should eq oauth_token  }
        end
      end
    end

    describe 'oauth authentication' do
      let(:authentication_request) { oauth_refresh_authentication_request }

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

  describe '.authentication_middleware' do
    subject { client.send :authentication_middleware }

    context 'without required options for authentication middleware to be provided' do
      let(:client_options) { {} }

      it { should be_nil }
    end
  end
  
  describe '.describe_sobjects' do
    subject { client.describe_sobjects }

    before do
      stub_api_request :sobjects, with: 'sobject/describe_sobjects_success_response'
    end

    it { should be_an Array }
  end

  describe '.list_sobjects' do
    subject { client.list_sobjects }

    before do
      stub_api_request :sobjects, with: 'sobject/describe_sobjects_success_response'
    end

    it { should be_an Array }
    it { should eq ['Account'] }
  end
end
