require 'spec_helper'

describe Restforce::Middleware::Gzip do
  let(:app)        { double('app')            }
  let(:env)        { { :request_headers => {}, :response_headers => {} }  }
  let(:options)    { { :oauth_token => 'token' } }
  let(:middleware) { described_class.new app, nil, options }

  # Return a gzipped string.
  def gzip(str)
    StringIO.new.tap do |io|
      gz = Zlib::GzipWriter.new(io)
      gz.write(str)
      gz.close
    end.string
  end

  describe 'request' do
    before do
      app.should_receive(:on_complete) { middleware.on_complete(env) }
      app.should_receive(:call).and_return(app)
    end

    context 'when :compress is false' do
      it 'does not add the Accept-Encoding header' do
        middleware.call(env)
        expect(env[:request_headers]['Accept-Encoding']).to be_nil
      end
    end

    context 'when :compress is true' do
      before do
        options[:compress] = true
      end

      it 'adds the Accept-Encoding header' do
        middleware.call(env)
        expect(env[:request_headers]['Accept-Encoding']).to eq 'gzip'
      end
    end
  end

  describe 'response' do
    before do
      app.should_receive(:on_complete) { middleware.on_complete(env) }
      app.should_receive(:call) do
        env[:body] = gzip fixture('sobject/query_success_response')
        env[:response_headers]['Content-Encoding'] = 'gzip'
        app
      end
    end

    it 'decompresses the response body' do
      middleware.call(env)
      expect(env[:body]).to eq fixture('sobject/query_success_response')
    end
  end

  describe '.decompress' do
    let(:body) { gzip fixture('sobject/query_success_response') }

    subject { middleware.decompress(body) }
    it { should eq fixture('sobject/query_success_response') }
  end

  describe '.gzipped?' do
    subject { middleware.gzipped?(env) }

    context 'when gzipped' do
      before do
        env[:response_headers]['Content-Encoding'] = 'gzip'
      end

      it { should be_true }
    end

    context 'when not gzipped' do
      it { should be_false }
    end
  end
end
