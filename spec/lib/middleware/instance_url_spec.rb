require 'spec_helper'

describe Restforce::Middleware::InstanceURL do
  let(:app)        { double('app') }
  let(:client)     { double('client') }
  let(:options)    { { :instance_url => instance_url } }
  let(:middleware) { described_class.new app, client, options }
  
  context 'when the instance url is not set' do
    let(:instance_url) { nil }

    it 'raises an error' do
      expect {
        middleware.call(nil)
      }.to raise_error Restforce::UnauthorizedError
    end
  end

  context 'when the instance url is set' do
    let(:instance_url) { 'https://foo.bar' }

    before do
      client.stub_chain(:connection, :url_prefix).and_return URI.parse(url_prefix)
    end

    context 'and it does not match the connection url prefix' do
      let(:url_prefix) { 'https://whiz.bang' }

      it 'raises an error' do
        expect {
          middleware.call(nil)
        }.to raise_error Restforce::InstanceURLError
      end
    end

    context 'and it matches the connection url prefix' do
      let(:url_prefix) { 'https://foo.bar' }
      
      before do
        app.should_receive(:call)
      end

      it 'calls tne next middleware' do
        middleware.call(nil)
      end
    end
  end
end
