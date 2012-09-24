require 'spec_helper'

describe Restforce::Middleware::Authentication do
  let(:app)        { double('app')            }
  let(:env)        { { }  }
  let(:retries)    { 3 }
  let(:options)    { { host: 'login.salesforce.com', authentication_retries: retries } }
  let(:middleware) { described_class.new app, nil, options }

  describe '.authenticate!' do
    it 'raises an error' do
      expect {
        middleware.authenticate!
      }.to raise_error RuntimeError, 'not implemented'
    end
  end

  describe '.call' do
    context 'when all is good' do
      before do
        app.should_receive(:call).once
      end

      it 'calls the next middlware' do
        middleware.call(env)
      end
    end

    context 'when an exception is thrown' do
      before do
        env[:body] = 'foo'
        env[:request] = {proxy: nil}
      end

      it 'attempts to authenticate' do
        app.should_receive(:call).once.and_raise(Restforce::UnauthorizedError.new('something bad'))
        middleware.should_receive(:authenticate!)
        expect { middleware.call(env) }.to raise_error Restforce::UnauthorizedError
      end
    end
  end

  describe '.connection' do
    subject { middleware.connection }

    its(:url_prefix) { should eq URI.parse('https://login.salesforce.com') }

    describe '.builder' do
      subject { middleware.connection.builder }

      context 'with logging disabled' do
        before do
          Restforce.stub!(:log?).and_return(false)
        end

        its(:handlers) { should include FaradayMiddleware::ParseJson, Faraday::Adapter::NetHttp }
        its(:handlers) { should_not include Restforce::Middleware::Logger  }
      end

      context 'with logging enabled' do
        before do
          Restforce.stub!(:log?).and_return(true)
        end

        its(:handlers) { should include FaradayMiddleware::ParseJson, Restforce::Middleware::Logger, Faraday::Adapter::NetHttp }
      end
    end
  end
end
