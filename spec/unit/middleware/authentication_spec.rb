# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::Authentication do
  let(:options) do
    { host: 'login.salesforce.com',
      proxy_uri: 'https://not-a-real-site.com',
      authentication_retries: retries,
      adapter: :net_http,
      # rubocop:disable Naming/VariableNumber
      ssl: { version: :TLSv1_2 } }
    # rubocop:enable Naming/VariableNumber
  end

  describe '.authenticate!' do
    context 'without params' do
      it 'raises' do
        expect { middleware.authenticate! }.to raise_error NotImplementedError
      end
    end

    context 'with params' do
      before { allow(middleware).to receive(:params).and_return({foo: :bar}) }

      context 'with a successful reauth' do
        let(:reauth_success_response) { fixture(:reauth_success_response) }
        let(:mashed_reauth_success_response) { Restforce::Mash.new(JSON.parse(reauth_success_response)) }

        before do
          stub_request(:post, "https://login.salesforce.com/services/oauth2/token").
            with(:body => {"foo"=>"bar"},
                 :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
            to_return(:status => 200, :body => reauth_success_response, :headers => {'Content-Type' => 'application/json;charset=UTF-8'})
        end

        it 'returns the response body' do
          expect(middleware.authenticate!).to eq mashed_reauth_success_response
        end

        context 'with an authentication wrapper' do
          it 'calls the authentication wrapper' do
            # Test setup happens here so both setup and expectation have access to wrapper_called
            wrapper_called = false
            auth_wrapper = ->(&block) { wrapper_called = true; block.call }
            options.merge!(:authentication_wrapper => auth_wrapper)

            middleware.authenticate!
            expect(wrapper_called).to be_true
          end

          it 'returns the response body' do
            auth_wrapper = ->(&block) { result = block.call; wrapper_called = true; result }
            options.merge!(:authentication_wrapper => auth_wrapper)
            expect(middleware.authenticate!).to eq mashed_reauth_success_response
          end
        end
      end

      context 'with a failed reauth' do
        let(:refresh_error_response) { fixture(:refresh_error_response) }
        let(:mashed_refresh_error_response) { Restforce::Mash.new(JSON.parse(refresh_error_response)) }

        before do
          stub_request(:post, "https://login.salesforce.com/services/oauth2/token").
            with(:body => {"foo"=>"bar"},
                 :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
            to_return(:status => 400, :body => refresh_error_response, :headers => {'Content-Type' => 'application/json;charset=UTF-8'})
        end

        it 'raises AuthenticationError' do
          expect { middleware.authenticate! }.to raise_error Restforce::AuthenticationError
        end
      end
    end
  end

  describe '.call' do
    subject { lambda { middleware.call(env) } }

    context 'when successfull' do
      before do
        app.should_receive(:call).once
      end

      it { should_not raise_error }
    end

    context 'when an exception is thrown' do
      before do
        env.stub body: 'foo', request: { proxy: nil }
        middleware.stub :authenticate!
        app.should_receive(:call).once.
          and_raise(Restforce::UnauthorizedError.new('something bad'))
      end

      it { should raise_error Restforce::UnauthorizedError }
    end
  end

  describe '.connection' do
    subject(:connection) { middleware.connection }

    its(:url_prefix)     { should eq(URI.parse('https://login.salesforce.com')) }

    it "should have a proxy URI" do
      connection.proxy[:uri].should eq(URI.parse('https://not-a-real-site.com'))
    end

    describe '.builder' do
      subject(:builder) { connection.builder }

      context 'with logging disabled' do
        before do
          Restforce.stub log?: false
        end

        its(:handlers) {
          should include Restforce::Middleware::JsonResponse
        }
        its(:handlers) { should_not include Restforce::Middleware::Logger }
        its(:adapter) { should eq Faraday::Adapter::NetHttp }
      end

      context 'with logging enabled' do
        before do
          Restforce.stub log?: true
        end

        its(:handlers) {
          should include Restforce::Middleware::JsonResponse,
                         Restforce::Middleware::Logger
        }
        its(:adapter) { should eq Faraday::Adapter::NetHttp }
      end

      context 'with specified adapter' do
        before do
          options[:adapter] = :typhoeus
        end

        its(:handlers) {
          should include Restforce::Middleware::JsonResponse
        }
        its(:adapter) { should eq Faraday::Adapter::Typhoeus }
      end
    end

    it "should have SSL config set" do
      # rubocop:disable Naming/VariableNumber
      connection.ssl[:version].should eq(:TLSv1_2)
      # rubocop:enable Naming/VariableNumber
    end
  end

  describe '.error_message' do
    context 'when response_body is present' do
      let(:response) {
        Faraday::Response.new(
          response_body: { 'error' => 'error', 'error_description' => 'description' },
          status: 401
        )
      }

      subject { middleware.error_message(response) }
      it { should eq "error: description (401)" }
    end

    context 'when response_body is nil' do
      let(:response) { Faraday::Response.new(status: 401) }

      subject { middleware.error_message(response) }
      it { should eq "401" }
    end
  end
end
