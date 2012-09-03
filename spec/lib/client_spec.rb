require 'spec_helper'

shared_examples_for 'methods' do
  describe '#new' do
    context 'without options passed in' do
      it 'should not raise an exception' do
        expect {
          described_class.new
        }.to_not raise_error
      end
    end

    context 'with a non-hash value' do
      it 'should raise an exception' do
        expect {
          described_class.new 'foo'
        }.to raise_error, 'Please specify a hash of options'
      end
    end
  end

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

  describe '.search' do
    before do
      stub_api_request :search, with: 'sobject/search_success_response'
    end

    subject { client.search('FIND {bar}') }
    it { should be_an Array }
    its(:size) { should eq 2 }
  end

  describe '.org_id' do
    before do
      stub_api_request :query, with: 'sobject/org_query_response'
    end

    subject { client.org_id }
    it { should eq '00Dx0000000BV7z' }
  end

  describe '.create' do
    before do
      stub_api_request 'sobjects/Account', with: 'sobject/create_success_response', method: :post
    end

    subject { client.create('Account', Name: 'Foobar') }
    it { should eq 'some_id' }
  end

  describe '.update' do
    pending 'with invalid Id'
    pending 'with missing Id'
    context 'with success' do
      before do
        @request = stub_api_request 'sobjects/Account/001D000000INjVe', method: :patch
      end

      after do
        @request.should have_been_requested
      end

      context 'with symbol Id key' do
        subject { client.update('Account', Id: '001D000000INjVe', Name: 'Foobar') }
        it { should be_true }
      end

      context 'with string Id key' do
        subject { client.update('Account', 'Id' => '001D000000INjVe', 'Name' => 'Foobar') }
        it { should be_true }
      end
    end
  end

  describe '.destroy' do
    pending 'with invalid Id'

    context 'with success' do
      before do 
        @request = stub_api_request 'sobjects/Account/001D000000INjVe', method: :delete
      end

      after do
        @request.should have_been_requested
      end

      subject { client.destroy('Account', '001D000000INjVe') }
      it { should be_true }
    end
  end
end

describe 'with mashify middleware' do
  describe Restforce::Client do
    include_context 'basic client'
    include_examples 'methods'

    describe '.mashify?' do
      subject { client.send :mashify? }

      it { should be_true }
    end

    describe '.query' do
      context 'with pagination' do
        before do
          @requests = [].tap do |requests|
            requests << stub_api_request('query\?q', with: 'sobject/query_paginated_first_page_response')
            requests << stub_api_request('query/01gD', with: 'sobject/query_paginated_last_page_response')
          end
        end

        after do
          @requests.each { |request| request.should have_been_requested }
        end

        subject { client.query('SELECT some, fields FROM object').next_page }
        it { should be_a Restforce::Collection }
        specify { subject.first.Text_Label.should eq 'Last Page' }
      end
    end
  end
end

describe 'without mashify middleware' do
  before do
    client.send(:connection).builder.delete(Restforce::Middleware::Mashify)
  end

  describe Restforce::Client do
    include_context 'basic client'
    include_examples 'methods'
    
    describe '.mashify?' do
      subject { client.send :mashify? }

      it { should be_false }
    end
  end
end
