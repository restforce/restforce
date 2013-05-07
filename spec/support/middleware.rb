module MiddlewareExampleGroup
  def self.included(base)
    base.class_eval do
      let(:app)            { double('@app', :call => nil)            }
      let(:env)            { { :request_headers => {}, :response_headers => {} } }
      let(:retries)        { 3 }
      let(:options)        { { } }
      let(:client)         { double(Restforce::AbstractClient) }
      subject(:middleware) { described_class.new app, client, options }
    end
  end

  RSpec.configure do |config|
    config.include self,
      :example_group => { :file_path => %r{spec/unit/middleware} }
  end
end

shared_examples_for 'authentication middleware' do
  describe '.authenticate!' do
    after do
      request.should have_been_requested
    end

    context 'when successful' do
      let!(:request) { success_request }

      before do
        middleware.authenticate!
      end

      describe '@options' do
        subject { options }

        its([:instance_url]) { should eq 'https://na1.salesforce.com' }
        its([:oauth_token])  { should eq '00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW19ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs' }
      end
    end

    context 'when unsuccessful' do
      let!(:request) { fail_request }

      it 'raises an exception' do
        expect {
          middleware.authenticate!
        }.to raise_error Restforce::AuthenticationError, /^invalid_grant: .*/
      end
    end
  end
end
