# frozen_string_literal: true

module MiddlewareExampleGroup
  def self.included(base)
    base.class_eval do
      let(:app)            { double('@app', call: nil) }
      let(:env)            { { request_headers: {}, response_headers: {} } }
      let(:retries)        { 3 }
      let(:options)        { {} }
      let(:client)         { double(Restforce::AbstractClient) }
      let(:auth_callback)  { double(Proc) }

      let(:success_response) do
        Restforce::Mash.new(JSON.parse(fixture(:auth_success_response)))
      end

      subject(:middleware) { described_class.new app, client, options }
    end
  end

  RSpec.configure do |config|
    config.include self, file_path: %r{spec/unit/middleware}
  end
end

shared_examples_for 'authentication middleware' do
  describe '.authenticate!' do
    after do
      request.should have_been_requested
    end

    context 'when successful' do
      let!(:request) { success_request }

      describe '@options' do
        subject { options }

        before do
          middleware.authenticate!
        end

        its([:instance_url]) { should eq 'https://na1.salesforce.com' }

        its([:oauth_token])  do
          should eq "00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtv" \
                    "xjTrKW19ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs"
        end
      end

      context 'when an authentication_callback is specified' do
        before(:each) do
          options.merge!(authentication_callback: auth_callback)
        end

        it 'calls the authentication callback with the response body' do
          auth_callback.should_receive(:call).with(success_response)
          middleware.authenticate!
        end
      end
    end

    context 'when unsuccessful' do
      let!(:request) { fail_request }

      it 'raises an exception' do
        expect {
          middleware.authenticate!
        }.to raise_error Restforce::AuthenticationError, /^invalid_grant: .*/
      end

      context 'when an authentication_callback is specified' do
        before(:each) do
          options.merge!(authentication_callback: auth_callback)
        end

        it 'does not call the authentication callback' do
          auth_callback.should_not_receive(:call)
          expect do
            middleware.authenticate!
          end.to raise_error
        end
      end
    end
  end
end
