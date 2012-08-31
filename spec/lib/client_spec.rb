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

  describe '.authentication_middleware' do
    subject { client.send :authentication_middleware }

    context 'without required options for authentication middleware to be provided' do
      let(:client_options) { {} }

      it { should be_nil }
    end

    context 'with username, password, security token, client id and client secret provided' do
      let(:client_options) { password_options }

      it { should eq Restforce::Middleware::Authentication::Password }
    end

    context 'with oauth token, refresh token, client id and client secret provided' do
      let(:client_options) { oauth_options }

      it { should eq Restforce::Middleware::Authentication::OAuth }
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

  describe '.query' do
    subject { client.query('SELECT some, fields FROM object') }

    before do
      stub_api_request :query, with: 'sobject/query_success_response'
    end

    it { should be_a Restforce::Collection }
  end
end
