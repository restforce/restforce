# frozen_string_literal: true

require 'spec_helper'

shared_examples_for Restforce::AbstractClient do
  describe '.list_sobjects' do
    requests :sobjects, fixture: 'sobject/describe_sobjects_success_response'

    subject { client.list_sobjects }
    it { should be_an Array }
    it { should eq ['Account'] }
  end

  describe '.describe' do
    context 'with no arguments' do
      requests :sobjects, fixture: 'sobject/describe_sobjects_success_response'

      subject { client.describe }
      it { should be_an Array }
    end

    context 'with an argument' do
      requests 'sobjects/Whizbang/describe',
               fixture: 'sobject/sobject_describe_success_response'

      subject { client.describe('Whizbang') }
      its(['name']) { should eq 'Whizbang' }
    end
  end

  describe '.query' do
    requests 'query\?q=SELECT%20some,%20fields%20FROM%20object',
             fixture: 'sobject/query_success_response'

    subject { client.query('SELECT some, fields FROM object') }
    it { should be_an Enumerable }
  end

  describe '.get_updated' do
    let(:start_date) { Time.new(2015, 8, 17, 0, 0, 0, "+02:00") }
    let(:end_date) { Time.new(2016, 8, 19, 0, 0, 0, "+02:00") }
    end_string = '2016-08-18T22:00:00Z'
    start_string = '2015-08-16T22:00:00Z'
    requests "sobjects/Whizbang/updated/\\?end=#{end_string}&start=#{start_string}",
             fixture: 'sobject/get_updated_success_response'
    subject { client.get_updated('Whizbang', start_date, end_date) }
    it { should be_an Enumerable }
  end

  describe '.get_deleted' do
    let(:start_date) { Time.new(2015, 8, 17, 0, 0, 0, "+02:00") }
    let(:end_date) { Time.new(2016, 8, 19, 0, 0, 0, "+02:00") }
    end_string = '2016-08-18T22:00:00Z'
    start_string = '2015-08-16T22:00:00Z'
    requests "sobjects/Whizbang/deleted/\\?end=#{end_string}&start=#{start_string}",
             fixture: 'sobject/get_deleted_success_response'
    subject { client.get_deleted('Whizbang', start_date, end_date) }
    it { should be_an Enumerable }
  end

  describe '.search' do
    requests 'search\?q=FIND%20%7Bbar%7D', fixture: 'sobject/search_success_response'

    subject { client.search('FIND {bar}') }
    it { should be_an Array }
    its(:size) { should eq 2 }
  end

  describe '.org_id' do
    requests 'query\?q=select%20id%20from%20Organization',
             fixture: 'sobject/org_query_response'

    subject { client.org_id }
    it { should eq '00Dx0000000BV7z' }
  end

  describe '.create' do
    context 'without multipart' do
      requests 'sobjects/Account',
               method: :post,
               with_body: "{\"Name\":\"Foobar\"}",
               fixture: 'sobject/create_success_response'

      subject { client.create('Account', Name: 'Foobar') }
      it { should eq 'some_id' }
    end

    context 'with multipart' do
      # rubocop:disable Layout/LineLength
      requests 'sobjects/Account',
               method: :post,
               with_body: %r(----boundary_string\r\nContent-Disposition: form-data; name="entity_content"\r\nContent-Type: application/json\r\n\r\n{"Name":"Foobar"}\r\n----boundary_string\r\nContent-Disposition: form-data; name="Blob"; filename="blob.jpg"\r\nContent-Length: 42171\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary),
               fixture: 'sobject/create_success_response'
      # rubocop:enable Layout/LineLength

      subject do
        client.create('Account', Name: 'Foobar',
                                 Blob: Restforce::FilePart.new(
                                   File.expand_path('../fixtures/blob.jpg', __dir__),
                                   'image/jpeg'
                                 ))
      end

      it { should eq 'some_id' }

      context 'with deprecated UploadIO' do
        subject do
          client.create('Account', Name: 'Foobar',
                        Blob: Restforce::UploadIO.new(
                          File.expand_path('../fixtures/blob.jpg', __dir__),
                          'image/jpeg'
                        ))
        end

        it { should eq 'some_id' }
      end
    end
  end

  describe '.update!' do
    context 'with invalid Id' do
      requests 'sobjects/Account/001D000000INjVe',
               method: :patch,
               with_body: "{\"Name\":\"Foobar\"}",
               status: 404,
               fixture: 'sobject/delete_error_response'

      let(:error) do
        JSON.parse(fixture('sobject/delete_error_response'))
      end

      it "raises Faraday::ResourceNotFound" do
        expect { client.update!('Account', Id: '001D000000INjVe', Name: 'Foobar') }.
          to raise_error do |exception|
            expect(exception).to be_a(Faraday::ResourceNotFound)

            expect(exception.message).
              to start_with("#{error.first['errorCode']}: #{error.first['message']}")
          end
      end
    end
  end

  describe '.update' do
    context 'with missing Id' do
      subject { lambda { client.update('Account', Name: 'Foobar') } }
      it { should raise_error ArgumentError, 'ID field missing from provided attributes' }
    end

    context 'with invalid Id' do
      requests 'sobjects/Account/001D000000INjVe',
               method: :patch,
               with_body: "{\"Name\":\"Foobar\"}",
               status: 404,
               fixture: 'sobject/delete_error_response'

      subject { client.update('Account', Id: '001D000000INjVe', Name: 'Foobar') }
      it { should be false }
    end

    context 'with success' do
      requests 'sobjects/Account/001D000000INjVe',
               method: :patch,
               with_body: "{\"Name\":\"Foobar\"}"

      [:Id, :id, 'Id', 'id'].each do |key|
        context "with #{key.inspect} as the key" do
          subject do
            client.update('Account', key => '001D000000INjVe', :Name => 'Foobar')
          end

          it { should be true }
        end
      end
    end
  end

  describe '.upsert!' do
    context 'when updated' do
      requests 'sobjects/Account/External__c/foobar',
               method: :patch,
               with_body: "{\"Name\":\"Foobar\"}",
               fixture: "sobject/upsert_updated_success_response"

      context 'with symbol external Id key' do
        subject do
          client.upsert!('Account', 'External__c', External__c: 'foobar',
                                                   Name: 'Foobar')
        end

        it { should be true }
      end

      context 'with string external Id key' do
        subject do
          client.upsert!('Account', 'External__c', 'External__c' => 'foobar',
                                                   'Name' => 'Foobar')
        end

        it { should be true }
      end
    end

    context 'when created' do
      requests 'sobjects/Account/External__c/foobar',
               method: :patch,
               with_body: "{\"Name\":\"Foobar\"}",
               fixture: 'sobject/upsert_created_success_response'

      [:External__c, 'External__c', :external__c, 'external__c'].each do |key|
        context "with #{key.inspect} as the external id" do
          subject do
            client.upsert!('Account', 'External__c', key => 'foobar',
                                                     :Name => 'Foobar')
          end

          it { should eq 'foo' }
        end
      end
    end

    context 'when created with a space in the id' do
      requests 'sobjects/Account/External__c/foo%20bar',
               method: :patch,
               with_body: "{\"Name\":\"Foobar\"}",
               fixture: 'sobject/upsert_created_success_response'

      [:External__c, 'External__c', :external__c, 'external__c'].each do |key|
        context "with #{key.inspect} as the external id" do
          subject do
            client.upsert!('Account', 'External__c', key => 'foo bar',
                                                     :Name => 'Foobar')
          end

          it { should eq 'foo' }
        end
      end
    end
  end

  describe '.destroy!' do
    subject(:destroy!) { client.destroy!('Account', '001D000000INjVe') }

    context 'with invalid Id' do
      requests 'sobjects/Account/001D000000INjVe',
               fixture: 'sobject/delete_error_response',
               method: :delete,
               status: 404

      subject { lambda { destroy! } }
      it { should raise_error Faraday::ResourceNotFound }
    end

    context 'with success' do
      requests 'sobjects/Account/001D000000INjVe', method: :delete

      it { should be true }
    end

    context 'with a space in the id' do
      subject(:destroy!) { client.destroy!('Account', '001D000000 INjVe') }
      requests 'sobjects/Account/001D000000%20INjVe', method: :delete

      it { should be true }
    end
  end

  describe '.destroy' do
    subject { client.destroy('Account', '001D000000INjVe') }

    context 'with invalid Id' do
      requests 'sobjects/Account/001D000000INjVe',
               fixture: 'sobject/delete_error_response',
               method: :delete,
               status: 404

      it { should be false }
    end

    context 'with success' do
      requests 'sobjects/Account/001D000000INjVe', method: :delete

      it { should be true }
    end
  end

  describe '.find' do
    context 'with no external id passed' do
      requests 'sobjects/Account/001D000000INjVe',
               fixture: 'sobject/sobject_find_success_response'

      subject { client.find('Account', '001D000000INjVe') }
      it { should be_a Hash }
    end

    context 'when an external id is passed' do
      requests 'sobjects/Account/External_Field__c/1234',
               fixture: 'sobject/sobject_find_success_response'

      subject { client.find('Account', '1234', 'External_Field__c') }
      it { should be_a Hash }
    end

    context 'with a space in an external id' do
      requests 'sobjects/Account/External_Field__c/12%2034',
               fixture: 'sobject/sobject_find_success_response'

      subject { client.find('Account', '12 34', 'External_Field__c') }
      it { should be_a Hash }
    end
  end

  describe '.select' do
    context 'when no external id is specified' do
      context 'when no select list is specified' do
        requests 'sobjects/Account/1234',
                 fixture: 'sobject/sobject_select_success_response'

        subject { client.select('Account', '1234', nil, nil) }
        it { should be_a Hash }
      end
      context 'when select list is specified' do
        requests 'sobjects/Account/1234\?fields=External_Field__c',
                 fixture: 'sobject/sobject_select_success_response'

        subject { client.select('Account', '1234', ['External_Field__c']) }
        it { should be_a Hash }
      end

      context 'with a space in the id' do
        requests 'sobjects/Account/12%2034',
                 fixture: 'sobject/sobject_select_success_response'

        subject { client.select('Account', '12 34', nil, nil) }
        it { should be_a Hash }
      end
    end

    context 'when an external id is specified' do
      context 'when no select list is specified' do
        requests 'sobjects/Account/External_Field__c/1234',
                 fixture: 'sobject/sobject_select_success_response'

        subject { client.select('Account', '1234', nil, 'External_Field__c') }
        it { should be_a Hash }
      end

      context 'when select list is specified' do
        requests 'sobjects/Account/External_Field__c/1234\?fields=External_Field__c',
                 fixture: 'sobject/sobject_select_success_response'

        subject do
          client.select('Account', '1234', ['External_Field__c'], 'External_Field__c')
        end

        it { should be_a Hash }
      end
    end
  end

  describe '.authenticate!' do
    subject(:authenticate!) { client.authenticate! }

    context 'when successful' do
      before do
        @request = stub_login_request(
          with_body: "grant_type=password&client_id=client_id" \
                     "&client_secret=client_secret&username=foo" \
                     "&password=barsecurity_token"
        ).to_return(status: 200, body: fixture(:auth_success_response))
      end

      after do
        expect(@request).to have_been_requested
      end

      it { should be_a Hash }
    end

    context 'when no authentication middleware is present' do
      before do
        client.stub(:authentication_middleware).and_return(nil)
      end

      it "raises an error" do
        expect { authenticate! }.to raise_error Restforce::AuthenticationError,
                                                'No authentication middleware present'
      end
    end
  end

  describe '.without_caching' do
    let(:cache) { MockCache.new }

    it 'deletes the cached value before querying the API' do
      stub = stub_api_request(
        'query\?q=SELECT%20some,%20fields%20FROM%20object',
        fixture: 'sobject/query_success_response'
      )
      client.query('SELECT some, fields FROM object')

      expect(cache).to receive(:delete).and_call_original.ordered
      expect(cache).to receive(:read).and_call_original.ordered
      client.without_caching { client.query('SELECT some, fields FROM object') }
      expect(stub).to have_been_requested.twice
    end
  end

  describe 'authentication retries' do
    context 'when retries reaches 0' do
      before do
        @auth_request = stub_api_request(
          'query\?q=SELECT%20some,%20fields%20FROM%20object',
          status: 401,
          fixture: 'expired_session_response'
        )

        @query_request = stub_login_request(
          with_body: "grant_type=password&client_id=client_id" \
                     "&client_secret=client_secret&username=foo&" \
                     "password=barsecurity_token"
        ).to_return(status: 200, body: fixture(:auth_success_response))
      end

      subject { lambda { client.query('SELECT some, fields FROM object') } }
      it { should raise_error Restforce::UnauthorizedError }
    end
  end

  describe '.query with caching' do
    let(:cache) { MockCache.new }

    before do
      @query = stub_api_request('query\?q=SELECT%20some,%20fields%20FROM%20object').
               with(headers: { 'Authorization' => "OAuth #{oauth_token}" }).
               to_return(status: 401,
                         body: fixture('expired_session_response'),
                         headers: { 'Content-Type' => 'application/json' }).then.
               to_return(status: 200,
                         body: fixture('sobject/query_success_response'),
                         headers: { 'Content-Type' => 'application/json' })

      @login = stub_login_request(
        with_body: "grant_type=password&client_id=client_id&client_secret=" \
                   "client_secret&username=foo&password=barsecurity_token"
      ).to_return(status: 200, body: fixture(:auth_success_response))
    end

    after do
      expect(@query).to have_been_made.times(2)
      expect(@login).to have_been_made
    end

    subject { client.query('SELECT some, fields FROM object') }
    it { should be_an Enumerable }
  end
end

describe Restforce::AbstractClient do
  describe 'with mashify' do
    it_behaves_like Restforce::AbstractClient

    describe '.query' do
      context 'with pagination' do
        subject { client.query('SELECT some, fields FROM object').next_page }

        requests 'query\?q', fixture: 'sobject/query_paginated_first_page_response'
        requests 'query/01gD', fixture: 'sobject/query_paginated_last_page_response'

        it { should be_a Restforce::Collection }
        its('first.Text_Label') { should eq 'Last Page' }
      end
    end
  end

  describe 'without mashify', mashify: false do
    it_behaves_like Restforce::AbstractClient
  end
end
