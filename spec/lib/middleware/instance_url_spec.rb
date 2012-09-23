require 'spec_helper'

describe Restforce::Middleware::InstanceURL do
  let(:app)        { double('app') }
  let(:client)     { double('client') }
  let(:options)    { { } }
  let(:middleware) { described_class.new app, client, options }
  
  context 'when the instance url is not set' do
    before do
      client.stub_chain(:connection, :url_prefix).and_return(URI.parse('http:/'))
    end

    it 'raises an exception' do
      expect {
        middleware.call(nil)
      }.to raise_error Restforce::UnauthorizedError
    end
  end

  context 'when the instance url is set' do
    before do
      client.stub_chain(:connection, :url_prefix).and_return(URI.parse('http://foobar.com/'))
    end

    it 'does not raise an exception' do
      app.should_receive(:call).once
      middleware.call(nil)
    end
  end
end
