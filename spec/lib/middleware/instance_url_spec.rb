require 'spec_helper'

describe Restforce::Middleware::InstanceURL do
  let(:app) { stub(call: nil) }
  let(:client) { stub(send: mock(url_prefix: URI.parse('https://whiz.bang'))) }
  let(:middleware) { described_class.new app, client, options }
  
  context 'when the instance url is not set' do
    let(:options) { { :instance_url => nil } }

    it 'raises an error' do
      expect {
        middleware.call(nil)
      }.to raise_error Faraday::Error::ClientError
    end
  end

  context 'when the instance url is set' do
    let(:options) { { :instance_url => 'https://foo.bar' } }

    context 'and it does not match the connection url prefix' do
      it 'raises an error' do
        expect {
          middleware.call(nil)
        }.to raise_error Restforce::InstanceURLError
      end
    end

    context 'and it matches the connection url prefix' do
      let(:client) { stub(send: mock(url_prefix: URI.parse('https://foo.bar'))) }

      it 'calls tne next middleware' do
        middleware.call(nil)
      end
    end
  end
end
