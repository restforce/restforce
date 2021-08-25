# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::Gzip do
  let(:options) { { oauth_token: 'token' } }

  # Return a gzipped string.
  def gzip(str)
    StringIO.new.tap do |io|
      gz = Zlib::GzipWriter.new(io)
      gz.write(str)
      gz.close
    end.string
  end

  describe '.call' do
    subject { lambda { middleware.call(env) } }

    before do
      app.should_receive(:on_complete) { middleware.on_complete(env) }
      app.should_receive(:call) do
        env[:body] = gzip fixture('sobject/query_success_response')
        env[:response_headers]['Content-Encoding'] = 'gzip'
        app
      end
    end

    it 'decompresses the body' do
      should change { env[:body] }.to(fixture('sobject/query_success_response'))
    end

    context 'when :compress is false' do
      it { should_not(change { env[:request_headers]['Accept-Encoding'] }) }
    end

    context 'when :compress is true' do
      before do
        options[:compress] = true
      end

      it { should(change { env[:request_headers]['Accept-Encoding'] }.to('gzip')) }
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

      it { should be true }
    end

    context 'when not gzipped' do
      it { should be false }
    end
  end
end
