# frozen_string_literal: true

require 'stringio'

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

    context 'when the response is gzipped' do
      before do
        app.should_receive(:on_complete) { middleware.on_complete(env) }
        app.should_receive(:call) do
          env[:body] = gzip fixture('sobject/query_success_response')
          env[:response_headers]['Content-Encoding'] = 'gzip'
          app
        end
      end

      it 'decompresses the body' do
        expect { subject.call }.to change {
                                     env[:body]
                                   }.to(fixture('sobject/query_success_response'))
      end

      context 'when :compress is false' do
        it 'does not set request headers to ask the response to be compressed' do
          expect { subject.call }.
            not_to(change { env[:request_headers]['Accept-Encoding'] })
        end
      end

      context 'when :compress is true' do
        before do
          options[:compress] = true
        end

        it 'sets request headers to ask the response to be compressed' do
          expect { subject.call }.to change {
                                       env[:request_headers]['Accept-Encoding']
                                     }.to('gzip')
        end
      end
    end

    context 'when the response claims to be gzipped, but is not' do
      before do
        app.should_receive(:on_complete) { middleware.on_complete(env) }
        app.should_receive(:call) do
          env[:body] = fixture('sobject/query_success_response')
          env[:response_headers]['Content-Encoding'] = 'gzip'
          app
        end
      end

      it 'does not decompress the body' do
        expect { subject.call }.to change {
                                     env[:body]
                                   }.to(fixture('sobject/query_success_response'))
      end
    end

    context 'when the response does not even claim to be gzipped' do
      before do
        app.should_receive(:on_complete) { middleware.on_complete(env) }
        app.should_receive(:call) do
          env[:body] = fixture('sobject/query_success_response')
          app
        end
      end

      it 'does not decompress the body' do
        expect { subject.call }.to change {
                                     env[:body]
                                   }.to(fixture('sobject/query_success_response'))
      end
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
