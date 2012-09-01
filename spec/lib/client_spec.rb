require 'spec_helper'

shared_examples_for 'instance methods' do
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
    before do
      stub_api_request :sobjects, with: 'sobject/describe_sobjects_success_response'
    end

    subject { client.describe_sobjects }
    it { should be_an Array }
  end

  describe '.list_sobjects' do
    before do
      stub_api_request :sobjects, with: 'sobject/describe_sobjects_success_response'
    end

    subject { client.list_sobjects }
    it { should be_an Array }
    it { should eq ['Account'] }
  end

  describe '.describe' do
    before do
      stub_api_request 'sobject/Whizbang/describe', with: 'sobject/sobject_describe_success_response'
    end

    subject { client.describe('Whizbang') }
    its(['name']) { should eq 'Whizbang' }
  end

  describe '.query' do
    before do
      stub_api_request :query, with: 'sobject/query_success_response'
    end

    subject { client.query('SELECT some, fields FROM object') }
    it { should be_an Array }
  end

  pending '.search' do
    before do
      stub_api_request :search, with: 'sobject/search_success_response'
    end

    subject { client.search('FIND {bar}') }
    it { puts subject }
  end

  describe '.org_id' do
    before do
      stub_api_request :query, with: 'sobject/org_query_response'
    end

    subject { client.org_id }
    it { should eq '00Dx0000000BV7z' }
  end
end

describe Restforce::Client do
  include_context 'basic client'

  context 'with mashify middleware' do
    include_examples 'instance methods'

    describe '.mashify?' do
      subject { client.send :mashify? }

      it { should be_true }
    end
  end

  context 'without mashify middleware' do
    before do
      client.send(:connection).builder.delete(Restforce::Middleware::Mashify)
    end

    include_examples 'instance methods'
    
    describe '.mashify?' do
      subject { client.send :mashify? }

      it { should be_false }
    end
  end
end
