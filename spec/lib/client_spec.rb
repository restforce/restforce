require 'spec_helper'

class MockCache
  def initialize
    @storage = {}
  end

  def fetch(key, &block)
    @storage[key] ||= block.call
  end

  def delete(key)
    @storage.delete(key)
  end
end

shared_examples_for 'methods' do
  describe '#new' do
    context 'without options passed in' do
      it 'does not raise an exception' do
        expect {
          described_class.new
        }.to_not raise_error
      end
    end

    context 'with a non-hash value' do
      it 'raises an exception' do
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

    context 'with refresh token, client id and client secret provided' do
      let(:client_options) { oauth_options }
      it { should eq Restforce::Middleware::Authentication::Token }
    end
  end

  describe '.list_sobjects' do
    requests :sobjects, :fixture => 'sobject/describe_sobjects_success_response'

    subject { client.list_sobjects }
    it { should be_an Array }
    it { should eq ['Account'] }
  end

  describe '.describe' do
    context 'with no arguments' do
      requests :sobjects, :fixture => 'sobject/describe_sobjects_success_response'

      subject { client.describe }
      it { should be_an Array }
    end

    context 'with an argument' do
      requests 'sobjects/Whizbang/describe', :fixture => 'sobject/sobject_describe_success_response'

      subject { client.describe('Whizbang') }
      its(['name']) { should eq 'Whizbang' }
    end
  end

  describe '.query' do
    requests 'query\?q=SELECT%20some,%20fields%20FROM%20object', :fixture => 'sobject/query_success_response'

    subject { client.query('SELECT some, fields FROM object') }
    it { should be_an Array }
  end

  describe '.search' do
    requests 'search\?q=FIND%20%7Bbar%7D', :fixture => 'sobject/search_success_response'

    subject { client.search('FIND {bar}') }
    it { should be_an Array }
    its(:size) { should eq 2 }
  end

  describe '.org_id' do
    requests 'query\?q=select%20id%20from%20Organization', :fixture => 'sobject/org_query_response'

    subject { client.org_id }
    it { should eq '00Dx0000000BV7z' }
  end

  describe '.create' do
    context 'without multipart' do
      requests 'sobjects/Account',
        :method => :post,
        :with_body => "{\"Name\":\"Foobar\"}",
        :fixture => 'sobject/create_success_response'

      subject { client.create('Account', :Name => 'Foobar') }
      it { should eq 'some_id' }
    end

    context 'with multipart' do
      requests 'sobjects/Account',
        :method => :post,
        :with_body => %r(----boundary_string\r\nContent-Disposition: form-data; name=\"entity_content\";\r\nContent-Type: application/json\r\n\r\n{\"Name\":\"Foobar\"}\r\n----boundary_string\r\nContent-Disposition: form-data; name=\"Blob\"; filename=\"blob.jpg\"\r\nContent-Length: 42171\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary),
        :fixture => 'sobject/create_success_response'

      subject { client.create('Account', :Name => 'Foobar', :Blob => Restforce::UploadIO.new(File.expand_path('../../fixtures/blob.jpg', __FILE__), 'image/jpeg')) }
      it { should eq 'some_id' }
    end
  end

  describe '.update!' do
    context 'with invalid Id' do
      requests 'sobjects/Account/001D000000INjVe',
        :method => :patch,
        :with_body => "{\"Name\":\"Foobar\"}",
        :status => 404,
        :fixture => 'sobject/delete_error_response'

      subject { client.update!('Account', :Id => '001D000000INjVe', :Name => 'Foobar') }
      specify { expect { subject }.to raise_error Faraday::Error::ResourceNotFound }
    end
  end

  describe '.update' do
    context 'with missing Id' do
      subject { client.update('Account', :Name => 'Foobar') }
      specify { expect { subject }.to raise_error RuntimeError, 'Id field missing.' }
    end

    context 'with invalid Id' do
      requests 'sobjects/Account/001D000000INjVe',
        :method => :patch,
        :with_body => "{\"Name\":\"Foobar\"}",
        :status => 404,
        :fixture => 'sobject/delete_error_response'

      subject { client.update('Account', :Id => '001D000000INjVe', :Name => 'Foobar') }
      it { should be_false }
    end

    context 'with success' do
      requests 'sobjects/Account/001D000000INjVe',
        :method => :patch,
        :with_body => "{\"Name\":\"Foobar\"}"

      [:Id, :id, 'Id', 'id'].each do |key|
        context "with #{key.inspect} as the key" do
          subject { client.update('Account', key => '001D000000INjVe', :Name => 'Foobar') }
          it { should be_true }
        end
      end
    end
  end

  describe '.upsert!' do
    context 'when updated' do
      requests 'sobjects/Account/External__c/foobar',
        :method => :patch,
        :with_body => "{\"Name\":\"Foobar\"}"

      context 'with symbol external Id key' do
        subject { client.upsert!('Account', 'External__c', :External__c => 'foobar', :Name => 'Foobar') }
        it { should be_true }
      end

      context 'with string external Id key' do
        subject { client.upsert!('Account', 'External__c', 'External__c' => 'foobar', 'Name' => 'Foobar') }
        it { should be_true }
      end
    end

    context 'when created' do
      requests 'sobjects/Account/External__c/foobar',
        :method => :patch,
        :with_body => "{\"Name\":\"Foobar\"}",
        :fixture => 'sobject/upsert_created_success_response'

      [:External__c, 'External__c', :external__c, 'external__c'].each do |key|
        context "with #{key.inspect} as the external id" do
          subject { client.upsert!('Account', 'External__c', key => 'foobar', :Name => 'Foobar') }
          it { should eq 'foo' }
        end
      end
    end
  end

  describe '.destroy!' do
    subject { client.destroy!('Account', '001D000000INjVe') }

    context 'with invalid Id' do
      requests 'sobjects/Account/001D000000INjVe',
        :fixture => 'sobject/delete_error_response',
        :method => :delete,
        :status => 404

      specify { expect { subject }.to raise_error Faraday::Error::ResourceNotFound }
    end

    context 'with success' do
      requests 'sobjects/Account/001D000000INjVe', :method => :delete

      it { should be_true }
    end
  end

  describe '.destroy' do
    subject { client.destroy('Account', '001D000000INjVe') }

    context 'with invalid Id' do
      requests 'sobjects/Account/001D000000INjVe',
        :fixture => 'sobject/delete_error_response',
        :method => :delete,
        :status => 404

      it { should be_false }
    end

    context 'with success' do
      requests 'sobjects/Account/001D000000INjVe', :method => :delete

      it { should be_true }
    end
  end

  describe '.find' do
    context 'with no external id passed' do
      requests 'sobjects/Account/001D000000INjVe',
        :fixture => 'sobject/sobject_find_success_response'

      subject { client.find('Account', '001D000000INjVe') }
      it { should be_a Hash }
    end

    context 'when an external id is passed' do
      requests 'sobjects/Account/External_Field__c/1234',
        :fixture => 'sobject/sobject_find_success_response'

      subject { client.find('Account', '1234', 'External_Field__c') }
      it { should be_a Hash }
    end
  end

  describe '.authenticate!' do
    before do
      @request = stub_login_request(:with_body => "grant_type=password&client_id=client_id&client_secret=" \
        "client_secret&username=foo&password=barsecurity_token").
        to_return(:status => 200, :body => fixture(:auth_success_response))
    end

    after do
      expect(@request).to have_been_requested
    end

    subject { client.authenticate! }
    specify { expect { subject }.to_not raise_error }
    it { should be_a Hash }
  end

  describe '.cache' do
    let(:cache) { double('cache') }

    subject { client.send :cache }
    it { should eq cache }
  end

  describe '.decode_signed_request' do
    subject { client.decode_signed_request(message) }

    context 'when the message is valid' do
      let(:data) { Base64.encode64('{ "key": "value" }') }
      let(:message) do
        digest = OpenSSL::Digest::Digest.new('sha256')
        signature = Base64.encode64(OpenSSL::HMAC.digest(digest, client_secret, data))
        "#{signature}.#{data}"
      end

      it { should eq('key' => 'value') }
    end

    context 'when the message is invalid' do
      let(:message) { 'foobar.awdkjkj' }
      it { should be_nil }
    end
  end

  describe '.middleware' do
    subject { client.middleware }
    it { should eq client.send(:connection).builder }

    context 'adding middleware' do
      before do
        client.middleware.use FaradayMiddleware::Instrumentation
      end

      its(:handlers) { should include FaradayMiddleware::Instrumentation }
    end
  end

  describe '.without_caching' do
    requests 'query\?q=SELECT%20some,%20fields%20FROM%20object',
      :fixture => 'sobject/query_success_response'

    before do
      cache.should_receive(:delete).and_call_original
      cache.should_receive(:fetch).and_call_original
    end

    let(:cache) { MockCache.new }
    subject { client.without_caching { client.query('SELECT some, fields FROM object') } }
    it { should be_an Array }
  end

  describe '.faye' do
    subject { client.send(:faye) }

    context 'with missing instance url' do
      let(:instance_url) { nil }
      specify { expect { subject }.to raise_error RuntimeError, 'Instance URL missing. Call .authenticate! first.' }
    end

    context 'with oauth token and instance url' do
      let(:instance_url) { 'http://foobar' }
      let(:oauth_token) { 'bar' }
      specify { expect { subject }.to_not raise_error }
    end
  end unless RUBY_PLATFORM == 'java'

  describe 'authentication retries' do
    context 'when retries reaches 0' do
      before do
        @auth_request = stub_api_request('query\?q=SELECT%20some,%20fields%20FROM%20object',
          :status => 401,
          :fixture => 'expired_session_response')
        @query_request = stub_login_request(:with_body => "grant_type=password&client_id=client_id&client_secret=" \
          "client_secret&username=foo&password=barsecurity_token").
          to_return(:status => 200, :body => fixture(:auth_success_response))
      end

      subject { client.query('SELECT some, fields FROM object') }
      specify { expect { subject }.to raise_error Restforce::UnauthorizedError }
    end
  end

  describe '.query with caching' do
    let(:cache) { MockCache.new }

    before do
      @query = stub_api_request('query\?q=SELECT%20some,%20fields%20FROM%20object').
        with(:headers => { 'Authorization' => "OAuth #{oauth_token}" }).
        to_return(:status => 401, :body => fixture('expired_session_response')).then.
        to_return(:status => 200, :body => fixture('sobject/query_success_response'))

      @login = stub_login_request(:with_body => "grant_type=password&client_id=client_id&client_secret=" \
        "client_secret&username=foo&password=barsecurity_token").
        to_return(:status => 200, :body => fixture(:auth_success_response))
    end

    after do
      expect(@query).to have_been_made.times(2)
      expect(@login).to have_been_made
    end

    subject { client.query('SELECT some, fields FROM object') }
    it { should be_an Array }
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
        requests 'query\?q', :fixture => 'sobject/query_paginated_first_page_response'
        requests 'query/01gD', :fixture => 'sobject/query_paginated_last_page_response'

        subject { client.query('SELECT some, fields FROM object').next_page }
        it { should be_a Restforce::Collection }
        specify { expect(subject.first.Text_Label).to eq 'Last Page' }
      end
    end
  end
end

describe 'without mashify middleware' do
  before do
    client.middleware.delete(Restforce::Middleware::Mashify)
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
