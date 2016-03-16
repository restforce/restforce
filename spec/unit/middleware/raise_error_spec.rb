require 'spec_helper'

describe Restforce::Middleware::RaiseError do
  let(:body)       { JSON.parse(fixture('sobject/query_error_response')) }
  let(:env)        { { status: status, body: body } }
  let(:middleware) { described_class.new app }

  describe '.on_complete' do
    subject(:on_complete) { middleware.on_complete(env) }

    context 'when the status code is 404' do
      let(:status) { 404 }

      it "raises an error" do
        expect { on_complete }.to raise_error Faraday::Error::ResourceNotFound,
                                              'INVALID_FIELD: error_message'
      end
    end

    context 'when the status code is 300' do
      let(:status) { 300 }

      it "raises an error" do
        expect { on_complete }.to raise_error Faraday::Error::ClientError,
                                              /300: The external ID provided/
      end
    end

    context 'when the status code is 400' do
      let(:status) { 400 }

      it "raises an error" do
        expect { on_complete }.to raise_error Faraday::Error::ClientError,
                                              'INVALID_FIELD: error_message'
      end
    end

    context 'when the status code is 401' do
      let(:status) { 401 }

      it "raises an error" do
        expect { on_complete }.to raise_error Restforce::UnauthorizedError,
                                              'INVALID_FIELD: error_message'
      end
    end

    context 'when the status code is 413' do
      let(:status) { 413 }

      it "raises an error" do
        expect { on_complete }.to raise_error Faraday::Error::ClientError,
                                              '413: Request Entity Too Large'
      end
    end

    context 'when status is 400+ and body is a string' do
      let(:body)   { 'An error occured' }
      let(:status) { 404 }

      it 'raises an error with a non-existing error code' do
        expect { on_complete }.to raise_error Faraday::Error::ClientError,
                                              "(error code missing): #{body}"
      end
    end
  end
end
