require 'spec_helper'

describe Restforce::Middleware::Authentication do
  let(:app)        { double('app')            }
  let(:env)        { { }  }
  let(:options)    { { host: 'login.salesforce.com' } }
  let(:middleware) { described_class.new app, nil, options }

  describe '.authenticate!' do
    it 'raises an error' do
      expect {
        middleware.authenticate!
      }.to raise_error RuntimeError, 'must subclass'
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
        app.should_receive(:call).once.and_raise(Restforce::UnauthorizedError.new('something bad'))
        middleware.should_receive(:authenticate!)
        app.should_receive(:call).once
      end

      it 'attempts to authenticate' do
        middleware.call(env)
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
        its(:handlers) { should_not include Faraday::Response::Logger  }
      end

      context 'with logging enabled' do
        before do
          Restforce.stub!(:log?).and_return(true)
        end

        its(:handlers) { should include FaradayMiddleware::ParseJson, Faraday::Response::Logger, Faraday::Adapter::NetHttp }
      end
    end
  end

  describe '.force_authenticate?' do
    subject { middleware.force_authenticate?(env) }

    context 'without X-ForceAuthenticate header set' do
      it { should be_false }
    end

    context 'with X-ForceAuthenticate header set' do
      before do
        env[:request_headers] = {}
        env[:request_headers]['X-ForceAuthenticate'] = true
      end

      it { should be_true }
    end
  end
end
